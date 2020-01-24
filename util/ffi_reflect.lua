--[[ LuaJIT FFI reflection Library ]]--
--[[ Copyright (C) 2014 Peter Cawley <lua@corsix.org>. All rights reserved.
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]
local ffi = require "ffi"
local bit = require "bit"
local reflect = {}

local CTState, init_CTState
local miscmap, init_miscmap

local function gc_str(gcref)
    -- Convert a GCref (to a GCstr) into a string
    if gcref ~= 0 then
        local ts = ffi.cast("uint32_t*", gcref)
        return ffi.string(ts + 4, ts[3])
    end
end

local typeinfo = ffi.typeinfo or function(id)
    -- ffi.typeof is present in LuaJIT v2.1 since 8th Oct 2014 (d6ff3afc)
    -- this is an emulation layer for older versions of LuaJIT
    local ctype = (CTState or init_CTState()).tab[id]
    return {
        info = ctype.info,
        size = bit.bnot(ctype.size) ~= 0 and ctype.size,
        sib  = ctype.sib ~= 0 and ctype.sib,
        name = gc_str(ctype.name),
    }
end

ffi.cdef(([[
typedef struct GCRef {
  %s gcptr;
} GCRef;
]]):format(ffi.abi "gc64" and "uint64_t" or "uint32_t"))
ffi.cdef [[
typedef struct GCcdata {
  GCRef nextgc; uint8_t marked; uint8_t gct;
  uint16_t ctypeid;	/* C type ID. */
} GCcdata;
]]

local function memptr(gcobj)
    return tonumber(tostring(gcobj):match "%x*$", 16)
end

function reflect.typeFromId(id)
    local cts = CTState or init_CTState()
    assert(0 < id and id < cts.top)
    local v = ffi.new('uint32_t', id)
    local p = ffi.cast('GCcdata*', memptr(v)) - 1
    p.ctypeid = 21
    return v
end

function reflect.typeFromName(name)
    local cts = CTState or init_CTState()
    for i = 1, cts.top - 1 do
        local ctype = cts.tab[i]
        if gc_str(ctype.name) == name then
            return reflect.typeFromId(i)
        end
    end
end

init_CTState = function()
    -- Relevant minimal definitions from lj_ctype.h
    ffi.cdef [[
    typedef struct CType {
      uint32_t info;
      uint32_t size;
      uint16_t sib;
      uint16_t next;
      uint32_t name;
    } CType;
    
    typedef struct CTState {
      CType *tab;
      uint32_t top;
      uint32_t sizetab;
      void *L;
      void *g;
      void *finalizer;
      void *miscmap;
    } CTState;
    ]]

    -- Acquire a pointer to this Lua universe's CTState
    local co = coroutine.create(function()
    end) -- Any live coroutine will do.
    local uintgc = ffi.abi "gc64" and "uint64_t" or "uint32_t"
    local uintgc_ptr = ffi.typeof(uintgc .. "*")
    local G = ffi.cast(uintgc_ptr, ffi.cast(uintgc_ptr, memptr(co))[2])
    -- In global_State, `MRef ctype_state` is immediately before `GCRef gcroot[GCROOT_MAX]`.
    -- We first find (an entry in) gcroot by looking for a metamethod name string.
    local anchor = ffi.cast(uintgc, ffi.cast("const char*", "__index"))
    local i = 0
    while math.abs(tonumber(G[i] - anchor)) > 64 do
        i = i + 1
    end
    -- We then work backwards looking for something resembling ctype_state.
    repeat
        i = i - 1
        CTState = ffi.cast("CTState*", G[i])
    until ffi.cast(uintgc_ptr, CTState.g) == G

    return CTState
end

init_miscmap = function()
    -- Acquire the CTState's miscmap table as a Lua variable
    local t = {};
    t[0] = t
    local uptr = ffi.cast("uintptr_t", (CTState or init_CTState()).miscmap)
    if ffi.abi "gc64" then
        local tvalue = ffi.cast("uint64_t**", memptr(t))[2]
        tvalue[0] = bit.bor(bit.lshift(bit.rshift(tvalue[0], 47), 47), uptr)
    else
        local tvalue = ffi.cast("uint32_t*", memptr(t))[2]
        ffi.cast("uint32_t*", tvalue)[ffi.abi "le" and 0 or 1] = ffi.cast("uint32_t", uptr)
    end
    miscmap = t[0]
    return miscmap
end

-- Information for unpacking a `struct CType`.
-- One table per CT_* constant, containing:
-- * A name for that CT_
-- * Roles of the cid and size fields.
-- * Whether the sib field is meaningful.
-- * Zero or more applicable boolean flags.
local CTs = { [0] = { "int",
                      "", "size", false,
                      { 0x08000000, "bool" },
                      { 0x04000000, "float", "subwhat" },
                      { 0x02000000, "const" },
                      { 0x01000000, "volatile" },
                      { 0x00800000, "unsigned" },
                      { 0x00400000, "long" },
},
              { "struct",
                "", "size", true,
                { 0x02000000, "const" },
                { 0x01000000, "volatile" },
                { 0x00800000, "union", "subwhat" },
                { 0x00100000, "vla" },
              },
              { "ptr",
                "element_type", "size", false,
                { 0x02000000, "const" },
                { 0x01000000, "volatile" },
                { 0x00800000, "ref", "subwhat" },
              },
              { "array",
                "element_type", "size", false,
                { 0x08000000, "vector" },
                { 0x04000000, "complex" },
                { 0x02000000, "const" },
                { 0x01000000, "volatile" },
                { 0x00100000, "vla" },
              },
              { "void",
                "", "size", false,
                { 0x02000000, "const" },
                { 0x01000000, "volatile" },
              },
              { "enum",
                "type", "size", true,
              },
              { "func",
                "return_type", "nargs", true,
                { 0x00800000, "vararg" },
                { 0x00400000, "sse_reg_params" },
              },
              { "typedef", -- Not seen
                "element_type", "", false,
              },
              { "attrib", -- Only seen internally
                "type", "value", true,
              },
              { "field",
                "type", "offset", true,
              },
              { "bitfield",
                "", "offset", true,
                { 0x08000000, "bool" },
                { 0x02000000, "const" },
                { 0x01000000, "volatile" },
                { 0x00800000, "unsigned" },
              },
              { "constant",
                "type", "value", true,
                { 0x02000000, "const" },
              },
              { "extern", -- Not seen
                "CID", "", true,
              },
              { "kw", -- Not seen
                "TOK", "size",
              },
}

-- Set of CType::cid roles which are a CTypeID.
local type_keys = {
    element_type = true,
    return_type  = true,
    value_type   = true,
    type         = true,
}

-- Create a metatable for each CT.
local metatables = {
}
for _, CT in ipairs(CTs) do
    local what = CT[1]
    local mt = { __index = {} }
    metatables[what] = mt
end

-- Logic for merging an attribute CType onto the annotated CType.
local CTAs = { [0] = function(a, refct)
    error("TODO: CTA_NONE")
end,
               function(a, refct)
                   error("TODO: CTA_QUAL")
               end,
               function(a, refct)
                   a = 2 ^ a.value
                   refct.alignment = a
                   refct.attributes.align = a
               end,
               function(a, refct)
                   refct.transparent = true
                   refct.attributes.subtype = refct.typeid
               end,
               function(a, refct)
                   refct.sym_name = a.name
               end,
               function(a, refct)
                   error("TODO: CTA_BAD")
               end,
}

-- C function calling conventions (CTCC_* constants in lj_refct.h)
local CTCCs = { [0] = "cdecl",
                "thiscall",
                "fastcall",
                "stdcall",
}

local function refct_from_id(id)
    -- refct = refct_from_id(CTypeID)
    local ctype = typeinfo(id)
    local CT_code = bit.rshift(ctype.info, 28)
    local CT = CTs[CT_code]
    local what = CT[1]
    local refct = setmetatable({
                                   what   = what,
                                   typeid = id,
                                   name   = ctype.name,
                               }, metatables[what])

    -- Interpret (most of) the CType::info field
    for i = 5, #CT do
        if bit.band(ctype.info, CT[i][1]) ~= 0 then
            if CT[i][3] == "subwhat" then
                refct.what = CT[i][2]
            else
                refct[CT[i][2]] = true
            end
        end
    end
    if CT_code <= 5 then
        refct.alignment = bit.lshift(1, bit.band(bit.rshift(ctype.info, 16), 15))
    elseif what == "func" then
        refct.convention = CTCCs[bit.band(bit.rshift(ctype.info, 16), 3)]
    end

    if CT[2] ~= "" then
        -- Interpret the CType::cid field
        local k = CT[2]
        local cid = bit.band(ctype.info, 0xffff)
        if type_keys[k] then
            if cid == 0 then
                cid = nil
            else
                cid = refct_from_id(cid)
            end
        end
        refct[k] = cid
    end

    if CT[3] ~= "" then
        -- Interpret the CType::size field
        local k = CT[3]
        refct[k] = ctype.size or (k == "size" and "none")
    end

    if what == "attrib" then
        -- Merge leading attributes onto the type being decorated.
        local CTA = CTAs[bit.band(bit.rshift(ctype.info, 16), 0xff)]
        if refct.type then
            local ct = refct.type
            ct.attributes = {}
            CTA(refct, ct)
            ct.typeid = refct.typeid
            refct = ct
        else
            refct.CTA = CTA
        end
    elseif what == "bitfield" then
        -- Decode extra bitfield fields, and make it look like a normal field.
        refct.offset = refct.offset + bit.band(ctype.info, 127) / 8
        refct.size = bit.band(bit.rshift(ctype.info, 8), 127) / 8
        refct.type = {
            what     = "int",
            bool     = refct.bool,
            const    = refct.const,
            volatile = refct.volatile,
            unsigned = refct.unsigned,
            size     = bit.band(bit.rshift(ctype.info, 16), 127),
        }
        refct.bool, refct.const, refct.volatile, refct.unsigned = nil
    end

    if CT[4] then
        -- Merge sibling attributes onto this type.
        while ctype.sib do
            local entry = typeinfo(ctype.sib)
            if CTs[bit.rshift(entry.info, 28)][1] ~= "attrib" then
                break
            end
            if bit.band(entry.info, 0xffff) ~= 0 then
                break
            end
            local sib = refct_from_id(ctype.sib)
            sib:CTA(refct)
            ctype = entry
        end
    end

    return refct
end

local function sib_iter(s, refct)
    repeat
        local ctype = typeinfo(refct.typeid)
        if not ctype.sib then
            return
        end
        refct = refct_from_id(ctype.sib)
    until refct.what ~= "attrib" -- Pure attribs are skipped.
    return refct
end

local function siblings(refct)
    -- Follow to the end of the attrib chain, if any.
    while refct.attributes do
        refct = refct_from_id(refct.attributes.subtype or typeinfo(refct.typeid).sib)
    end

    return sib_iter, nil, refct
end

metatables.struct.__index.members = siblings
metatables.func.__index.arguments = siblings
metatables.enum.__index.values = siblings

local function find_sibling(refct, name)
    local num = tonumber(name)
    if num then
        for sib in siblings(refct) do
            if num == 1 then
                return sib
            end
            num = num - 1
        end
    else
        for sib in siblings(refct) do
            if sib.name == name then
                return sib
            end
        end
    end
end

metatables.struct.__index.member = find_sibling
metatables.func.__index.argument = find_sibling
metatables.enum.__index.value = find_sibling

--- reflect.typeof returns a so-called refct object, which describes the type passed in to the function.
---@return ffi.refct
function reflect.typeof(x)
    -- refct = reflect.typeof(ct)
    return refct_from_id(tonumber(ffi.typeof(x)))
end

--- reflect.getmetatable performs the inverse of ffi.metatype - given a ctype, it returns the corresponding metatable that was passed to ffi.metatype.
--- ## Example
--- reflect.getmetatable(ffi.metatype("struct {}", t)) == t
function reflect.getmetatable(x)
    -- mt = reflect.getmetatable(ct)
    return (miscmap or init_miscmap())[-tonumber(ffi.typeof(x))]
end

---@class ffi.refct
--- A refct object is one of 13 different kinds of type. For example, one of those kinds is "int", which covers all primitive integral types, and another is "ptr", which covers all pointer types. Perhaps unusually, every field within a structure is also considered to be a type, as is every argument within a function type, and every value within an enumerated type. While this may look odd, it results in a nice uniform API for type reflection. Note that typedefs are resolved by the parser, and are therefore not visible when reflected.
local _r = {}

--- All refct objects have a what field, which is a string denoting the kind of type. Other fields will also be present on a refct object, but these vary according to the kind.
_r.what = nil

--[[
"void" kind (refct.what)
Possible attributes: size, alignment, const, volatile.

The primitive empty type, optionally with a const and/or volatile qualifier. The actual type is therefore determined by the const and volatile fields.
Examples:
reflect.typeof("void").what == "void"
reflect.typeof("const void").what == "void"

---

"int" kind (refct.what)
Possible attributes: size, alignment, const, volatile, bool, unsigned, long.

A primitive integral type, such as bool or [const] [volatile] [u]int(8|16|32|64)_t. The in-memory type is determined by the size and unsigned fields, and the final quantified type determined also by the bool, const, and volatile fields.
Examples:
reflect.typeof("long").what == "int"
reflect.typeof("volatile unsigned __int64").what == "int"

---

"float" kind (refct.what)
Possible attributes: size, alignment, const, volatile.

A primitive floating point type, either [const] [volatile] float or [const] [volatile] double.
Examples:
reflect.typeof("double").what == "float"
reflect.typeof("const float").what == "float"

---

"enum" kind (refct.what)
Possible attributes: name, size, alignment, type.

Methods: values, value.

An enumerated type.
Example:
ffi.cdef "enum E{X,Y};"
reflect.typeof("enum E").what == "enum"

---

"constant" kind (refct.what)
Possible attributes: name, type, value.

A particular value within an enumerated type.
Example:
ffi.cdef "enum Bool{False,True};"
reflect.typeof("enum Bool"):value("False").what == "constant"

---

"ptr" kind (refct.what)
Possible attributes: size, alignment, const, volatile, element_type.

A pointer type (note that this includes function pointers). The type being pointed to is given by the element_type attribute.
Examples:
reflect.typeof("char*").what == "ptr"
reflect.typeof("int(*)(void)").what == "ptr"

---

"ref" kind (refct.what)
Possible attributes: size, alignment, const, volatile, element_type.

A reference type. The type being referenced is given by the element_type attribute.
Example:
reflect.typeof("char&").what == "ref"

---

"array" kind (refct.what)
Possible attributes: size, alignment, const, volatile, element_type, vla, vector, complex.

An array type. The type of each element is given by the element_type attribute. The number of elements is not directly available; instead the size attribute needs to be divided by element_type.size.
Examples:
reflect.typeof("char[16]").what == "array"
reflect.typeof("int[?]").what == "array"

---

"struct" kind (refct.what)
Possible attributes: name, size, alignment, const, volatile, vla, transparent.

Methods: members, member.

A structure aggregate type. The members of the structure can be enumerated through the members method, or indexed through the member method.
Example:
reflect.typeof("struct{int x; int y;}").what == "struct"

---

"union" kind (refct.what)
Possible attributes: name, size, alignment, const, volatile, transparent.

Methods: members, member.

A union aggregate type. The members of the union can be enumerated through the members method, or indexed through the member method.
Example:
reflect.typeof("union{int x; int y;}").what == "union"

---

"func" kind (refct.what)
Possible attributes: name, sym_name, return_type, nargs, vararg, sse_reg_params, convention.

Methods: arguments, argument.

A function aggregate type. Note that function pointers will be of the "ptr" kind, with a "func" kind as the element_type. The return type is available as the return_type attribute, while argument types can be enumerated through the arguments method, or indexed through the argument method. The number of arguments is determined from the nargs and vararg attributes.
Example:
ffi.cdef "int strcmp(const char*, const char*);"
reflect.typeof(ffi.C.strcmp).what == "func"
Example:
reflect.typeof("int(*)(void)").element_type.what == "func"

---

"field" kind (refct.what)
Possible attributes: name, offset, type.

An instance of a type within a structure or union, or an occurance of a type as an argument to a function.
Example:
reflect.typeof("struct{int x;}"):member("x").what == "field"
Example:
ffi.cdef "int strcmp(const char*, const char*);"
reflect.typeof(ffi.C.strcmp):argument(2).what == "field"

---

"bitfield" kind (refct.what)
Possible attributes: name, size, offset, type.

An instance of a type within a structure or union, which has an offset and/or size which is not a whole number of bytes.
Example:
reflect.typeof("struct{int x:2;}"):member("x").what == "bitfield"
]]

--

--- refct.name attribute (string or nil)
--- Applies to: struct, union, enum, func, field, bitfield, constant.
---
--- The type's given name, or nil if the type has no name.
--- ## Example
--- reflect.typeof("struct{int x; int y;}"):member(2).name == "y"
--- reflect.typeof("struct{int x; int y;}").name == nil
--- ffi.cdef 'int sc(const char*, const char*) __asm__("strcmp");'
--- reflect.typeof(ffi.C.sc).name == "sc"
_r.name = nil

--

--- refct.sym_name attribute (string or nil)
--- Applies to: func.
---
--- The function's symbolic name, if different to its given name.
--- ## Example
--- ffi.cdef 'int sc(const char*, const char*) __asm__("strcmp");'
--- reflect.typeof(ffi.C.sc).sym_name == "strcmp"
--- ffi.cdef "int strcmp(const char*, const char*);"
--- reflect.typeof(ffi.C.strcmp).sym_name == nil
_r.sym_name = nil

--

--- refct.size attribute (number or string)
--- Applies to: int, float, struct, union, ptr, ref, array, void, enum, bitfield.
---
--- The size of the type, in bytes. For most things this will be a strictly positive integer, although that is not always the case:
--- For empty structures and unions, size will be zero.
--- For types which are essentially void, size will be the string "none".
--- For bitfields, size can have a fractional part, which will be a multiple of 1/8.
--- For structures which terminate with a VLA, this will be the size of the fixed part of the structure.
--- For arrays, size will be the element size multiplied by the number of elements, or the string "none" if the number of elements is not known or not fixed.
--- ## Example
--- reflect.typeof("__int32").size == 4
--- reflect.typeof("__int32[2]").size == 8
--- reflect.typeof("__int32[]").size == "none"
--- reflect.typeof("__int32[?]").size == "none"
--- reflect.typeof("struct{__int32 count; __int32 data[?];}").size == 4
--- reflect.typeof("struct{}").size == 0
--- reflect.typeof("void").size == "none"
--- reflect.typeof("struct{int f:5;}"):member("f").size == 5 / 8
_r.size = nil

--

--- refct.offset attribute (number)
--- Applies to: field, bitfield.
---
--- For structure and union members, the number of bytes between the start of the containing type and the (bit)field. For a normal field, this will be a non-negative integer. For bitfields, this can have a fractional part which is a multiple of 1/8.
---
--- For function arguments, the zero-based index of the argument.
--- ## Example
--- reflect.typeof("struct{__int32 x; __int32 y; __int32 z;}"):member("z").offset == 8
--- reflect.typeof("struct{int x : 3; int y : 4; int z : 5;}"):member("z").offset == 7 / 8
--- reflect.typeof("int(*)(int x, int y)").element_type:argument("y").offset == 1
_r.offset = nil

--

--- refct.alignment attribute (integer)
--- Applies to: int, float, struct, union, ptr, ref, array, void, enum.
---
--- The minimum alignment required by the type, in bytes. Unless explicitly overridden by an alignment qualifier, this will be the value calculated by LuaJIT's C parser. In any case, this will be a power of two.
--- ## Example
--- reflect.typeof("struct{__int32 a; __int32 b;}").alignment == 4
--- reflect.typeof("__declspec(align(16)) int").alignment == 16
_r.alignment = nil

--

--- refct.const attribute (true or nil)
--- Applies to: int, float, struct, union, ptr, ref, array, void.
---
--- If true, this type was declared with the const qualifier. Be aware that for pointer types, this refers to the const-ness of the pointer itself, and not the const-ness of the thing being pointed to.
--- ## Example
--- reflect.typeof("int").const == nil
--- reflect.typeof("const int").const == true
--- reflect.typeof("const char*").const == nil
--- reflect.typeof("const char*").element_type.const == true
--- reflect.typeof("char* const").const == true
_r.const = nil

--

--- refct.volatile attribute (true or nil)
--- Applies to: int, float, struct, union, ptr, ref, array, void.
---
--- If true, this type was declared with the volatile qualifier. Note that this has no meaning to the JIT compiler. Be aware that for pointer types, this refers to the volatility of the pointer itself, and not the volatility of the thing being pointed to.
--- ## Example
--- reflect.typeof("int").volatile == nil
--- reflect.typeof("volatile int").volatile == true
_r.volatile = nil

--

--- refct.element_type attribute (refct)
--- Applies to: ptr, ref, array.
---
--- The type being pointed to (albeit implicitly in the case of a reference).
--- ## Example
--- reflect.typeof("char*").element_type.size == 1
--- reflect.typeof("char&").element_type.size == 1
--- reflect.typeof("char[32]").element_type.size == 1
_r.element_type = nil

--

--- refct.type attribute (refct)
--- Applies to: enum, field, bitfield, constant.
---
--- For (bit)fields, the type of the field.
--- ## Example
--- reflect.typeof("struct{float x; unsigned y;}"):member("y").type.unsigned == true
--- reflect.typeof("int(*)(uint64_t)").element_type:argument(1).type.size == 8
_r.type = nil

--

--- refct.return_type attribute (refct)
--- Applies to: func.
---
--- The return type of the function.
--- ## Example
--- ffi.cdef "int strcmp(const char*, const char*);"
--- reflect.typeof(ffi.C.strcmp).return_type.what == "int"
--- reflect.typeof("void*(*)(void)").element_type.return_type.what == "ptr"
_r.return_type = nil

--

--- refct.bool attribute (true or nil)
--- Applies to: int.
---
--- If true, reading from this type will give a Lua boolean rather than a Lua number.
--- ## Example
--- reflect.typeof("bool").bool == true
--- reflect.typeof("int").bool == nil
--- reflect.typeof("_Bool int").bool == true
_r.bool = nil

--

--- refct.unsigned attribute (true or nil)
--- Applies to: int.
---
--- If true, this type denotes an unsigned integer. Otherwise, it denotes a signed integer.
--- ## Example
--- reflect.typeof("int32_t").unsigned == nil
--- reflect.typeof("uint32_t").unsigned == true
_r.unsigned = nil

--

--- refct.long attribute (true or nil)
--- Applies to: int.
---
--- If true, this type was declared with the long qualifier. If calculating the size of the type, then use the size field rather than this field.
--- ## Example
--- reflect.typeof("long int").long == true
--- reflect.typeof("short int").long == nil
_r.long = nil

--

--- refct.vla attribute (true or nil)
--- Applies to: struct, array.
---
--- If true, this type has a variable length. Otherwise, this type has a fixed length.
--- ## Example
--- reflect.typeof("int[?]").vla == true
--- reflect.typeof("int[2]").vla == nil
--- reflect.typeof("int[]").vla == nil
--- reflect.typeof("struct{int num; int data[?];}").vla == true
--- reflect.typeof("struct{int num; int data[];}").vla == nil
_r.vla = nil

--

--- refct.transparent attribute (true or nil)
--- Applies to: struct, union.
---
--- If true, this type is an anonymous inner type. Such types have no name, and when using the FFI normally, their fields are accessed as fields of the containing type.
--- ## Example
--- for refct in reflect.typeof [[
--- struct {
---   int a;
---   union { int b; int c; };
---   struct { int d; int e; };
---   int f;
--- }
--- ]]:members() do print(refct.transparent) end --> nil, true, true, nil
_r.transparent = nil

--

--- refct.vector attribute (true or nil)
--- Applies to: array.
_r.vector = nil

--

--- refct.complex attribute (true or nil)
--- Applies to: array.
_r.complex = nil

--

--- refct.nargs attribute (integer)
--- Applies to: func.
---
--- The number of fixed arguments accepted by the function. If the vararg field is true, then additional arguments are accepted.
--- ## Example
--- ffi.cdef "int strcmp(const char*, const char*);"
--- reflect.typeof(ffi.C.strcmp).nargs == 2
--- ffi.cdef "int printf(const char*, ...);"
--- reflect.typeof(ffi.C.printf).nargs == 1
_r.nargs = nil

--

--- refct.vararg attribute (true or nil)
--- Applies to: func.
---
--- If true, the function accepts a variable number of arguments (i.e. the argument list declaration was terminated with ...).
--- ## Example
--- ffi.cdef "int strcmp(const char*, const char*);"
--- reflect.typeof(ffi.C.strcmp).vararg == nil
--- ffi.cdef "int printf(const char*, ...);"
--- reflect.typeof(ffi.C.printf).vararg == true
_r.vararg = nil

--

--- refct.sse_reg_params attribute (true or nil)
--- Applies to: func.
_r.sse_reg_params = nil

--

--- refct.convention attribute (string)
--- Applies to: func.
---
--- The calling convention that the function was declared with, which will be one of: "cdecl" (the default), "thiscall", "fastcall", "stdcall". Note that on Windows, LuaJIT will automatically change __cdecl to __stdcall after the first call to the function (if appropriate).
--- ## Example
--- reflect.typeof("int(__stdcall *)(int)").element_type.convention == "stdcall"
--- if not ffi.abi "win" then return "Windows-only example" end
--- ffi.cdef "void* LoadLibraryA(const char*)"
--- print(reflect.typeof(ffi.C.LoadLibraryA).convention) --> cdecl
--- ffi.C.LoadLibraryA("kernel32")
--- print(reflect.typeof(ffi.C.LoadLibraryA).convention) --> stdcall
_r.convention = nil

--

--- refct.value attribute (integer)
--- Applies to: constant.
_r.value = nil

--

--- refct iterator = refct:members()
--- Applies to: struct, union.
---
--- Returns an iterator triple which can be used in a for-in statement to enumerate the constituent members of the structure / union, in the order that they were defined. Each such member will be a refct of kind "field", "bitfield", "struct", or "union". The former two kinds will occur most of the time, with the latter two only occurring for unnamed (transparent) structures and unions. If enumerating the fields of a stucture or union, then you need to recursively enumerate these transparent members.
--- ## Example
--- for refct in reflect.typeof("struct{int x; int y;}"):members() do print(refct.name) end --> x, y
--- for refct in reflect.typeof[[
---   struct {
---     int a;
---     union {
---        int b;
---        int c;
---     };
---     int d : 2;
---     struct {
---       int e;
---       int f;
---     };
---   }
--- ]]:members() do print(refct.what) end --> field, union, bitfield, struct
function _r:members()
end

--

--- refct = refct:member(name_or_index)
--- Applies to: struct, union.
---
--- Like members(), but returns the first member whose name matches the given parameter, or the member given by the 1-based index, or nil if nothing matches. Note that this method takes time linear in the number of members.
function _r:member(name_or_index)
end

--

--- refct iterator = refct:arguments()
--- Applies to: func.
---
--- Returns an iterator triple which can be used in a for-in statement to enumerate the arguments of the function, from left to right. Each such argument will be a refct of kind "field", having a type attribute, zero-based offset attribute, and optionally a name attribute.
--- ## Example
--- ffi.cdef "int strcmp(const char*, const char*);"
--- for refct in reflect.typeof(ffi.C.strcmp):arguments() do print(refct.type.what) end --> ptr, ptr
--- for refct in reflect.typeof"int(*)(int x, int y)".element_type:arguments() do print(refct.name) end --> x, y
function _r:arguments()
end

--

--- refct = refct:argument(name_or_index)
--- Applies to: func.
---
--- Like arguments(), but returns the first argument whose name matches the given parameter, or the argument given by the 1-based index, or nil if nothing matches. Note that this method takes time linear in the number of arguments.
function _r:argument(name_or_index)
end

--

--- refct iterator = refct:values()
--- Applies to: enum.
---
--- Returns an iterator triple which can be used in a for-in statement to enumerate the values which make up an enumerated type. Each such value will be a refct of kind "constant", having name and value attributes.
--- ## Example
--- ffi.cdef "enum EV{EV_A = 1, EV_B = 10, EV_C = 100};"
--- for refct in reflect.typeof("enum EV"):values() do print(refct.name) end --> EV_A, EV_B, EV_C
function _r:values()
end

--

--- refct = refct:value(name_or_index)
--- Applies to: enum.
---
--- Like values(), but returns the value whose name matches the given parameter, or the value given by the 1-based index, or nil if nothing matches. Note that this method takes time linear in the number of values.
function _r:value(name_or_index)
end

return reflect
