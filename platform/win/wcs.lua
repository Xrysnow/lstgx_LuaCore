--- binding/wcs: utf8 <-> wide char conversions
--- Written by Cosmin Apreutesei. Public Domain.

--- 
local M = {}
local ffi = require('ffi')
local C = ffi.load('kernel32')
local util = require('platform.win.util')

ffi.cdef [[
size_t wcslen(const wchar_t *str);
wchar_t *wcsncpy(wchar_t *strDest, const wchar_t *strSource, size_t count);

int WideCharToMultiByte(
	  UINT     CodePage,
	  DWORD    dwFlags,
	  LPCWSTR  lpWideCharStr,
	  int      cchWideChar,
	  LPSTR    lpMultiByteStr,
	  int      cbMultiByte,
	  LPCSTR   lpDefaultChar,
	  LPBOOL   lpUsedDefaultChar);

int MultiByteToWideChar(
	  UINT     CodePage,
	  DWORD    dwFlags,
	  LPCSTR   lpMultiByteStr,
	  int      cbMultiByte,
	  LPWSTR   lpWideCharStr,
	  int      cchWideChar);
]]

M.CP_INSTALLED = 0x00000001  -- installed code page ids
M.CP_SUPPORTED = 0x00000002  -- supported code page ids
M.CP_ACP = 0           -- default to ANSI code page
M.CP_OEMCP = 1           -- default to OEM  code page
M.CP_MACCP = 2           -- default to MAC  code page
M.CP_THREAD_ACP = 3           -- current thread's ANSI code page
M.CP_SYMBOL = 42          -- SYMBOL translations
M.CP_UTF7 = 65000       -- UTF-7 translation
M.CP_UTF8 = 65001       -- UTF-8 translation

M.MB_PRECOMPOSED = 0x00000001  -- use precomposed chars
M.MB_COMPOSITE = 0x00000002  -- use composite chars
M.MB_USEGLYPHCHARS = 0x00000004  -- use glyph chars, not ctrl chars
M.MB_ERR_INVALID_CHARS = 0x00000008  -- error for invalid chars

local ERROR_INSUFFICIENT_BUFFER = 122

local checknz = util.checknz
local WCS_ctype = ffi.typeof 'WCHAR[?]'
local MB2WC = C.MultiByteToWideChar
local CP = M.CP_UTF8  --CP_* flags
local MB = 0        --MB_* flags

--- accept and convert a utf8-encoded Lua string to a WCHAR[?] buffer.
--- anything not a string passes through untouched.
--- return the cdata and the size in WCHARs (not bytes) minus the null terminator.
function M.wcs_sz(s)
    if type(s) ~= 'string' then
        return s
    end
    local sz = #s + 1 --assume 1 byte per character + null terminator
    local buf = WCS_ctype(sz)
    sz = MB2WC(CP, MB, s, #s + 1, buf, sz)
    if sz == 0 then
        if util.GetLastError() ~= ERROR_INSUFFICIENT_BUFFER then
            checknz(0)
        end
        sz = checknz(MB2WC(CP, MB, s, #s + 1, nil, 0))
        buf = WCS_ctype(sz)
        sz = checknz(MB2WC(CP, MB, s, #s + 1, buf, sz))
    end
    return buf, sz
end

--- same as wcs_sz but returns only the buffer. This allows you to pass wcs(s)
--- as the last argument of a ffi C call without the ffi bitching about excess args.
function M.wcs(s)
    return (M.wcs_sz(s))
end

--- Some APIs don't have a way to tell how large they need an input buffer
--- to be, but then again it doesn't matter much either because it's usually
--- about small strings. In those cases, we give 2Kchars (4 Kbytes) and move on.
M.DEFAULT_WCS_BUFFER_SIZE = 2048

--- wcs buffer constructor: allocate a WCHAR[?] buffer and return the buffer
--- and its size in WCHARs, minus the null-terminator.
--- 1. given a number, allocate a WCHAR buffer of size n + 1.
--- 2. given a WCHAR[?], return it along with its size in WCHARs minus the null terminator.
--- 3. given no args, make a default-size buffer.
function M.WCS(n)
    if type(n) == 'number' then
        return WCS_ctype(n + 1), n
    elseif ffi.istype(WCS_ctype, n) then
        return n, ffi.sizeof(n) / 2 - 1
    elseif n == nil then
        return WCS_ctype(M.DEFAULT_WCS_BUFFER_SIZE + 1), M.DEFAULT_WCS_BUFFER_SIZE
    end
    assert(false)
end

M.WC_COMPOSITECHECK = 0x00000200  -- convert composite to precomposed
M.WC_DISCARDNS = 0x00000010  -- discard non-spacing chars
M.WC_SEPCHARS = 0x00000020  -- generate separate chars
M.WC_DEFAULTCHAR = 0x00000040  -- replace w/ default char
M.WC_NO_BEST_FIT_CHARS = 0x00000400  -- do not use best fit chars

local MBS_ctype = ffi.typeof 'CHAR[?]'
local PWCS_ctype = ffi.typeof 'WCHAR*'
local WC2MB = C.WideCharToMultiByte
local WC = 0 --WC_* flags

--- accept and convert a WCHAR[?] or WCHAR* buffer to a Lua string.
--- anything else passes through.
function M.mbs(ws)
    if ffi.istype(WCS_ctype, ws) or ffi.istype(PWCS_ctype, ws) then
        local sz = checknz(WC2MB(M.CP_UTF8, WC, ws, -1, nil, 0, nil, nil))
        local buf = MBS_ctype(sz)
        checknz(WC2MB(M.CP_UTF8, WC, ws, -1, buf, sz, nil, nil))
        return ffi.string(buf, sz - 1) --sz includes null terminator
    else
        return ws
    end
end

function M.wcslen(str)
	return C.wcslen(str)
end

--- safer wcsncpy variant that null-terminates the result even on truncation.
function M.wcsncpy(dest, src, count)
    C.wcsncpy(dest, src, count)
    dest[count - 1] = 0
end

--- convert and store a utf8-encoded Lua string into a user-provided WCHAR[?] or WCHAR[n] cdata.
--- nil means empty string. anything else passes through.
--- if the dest. buffer is a WCHAR*, maxsz must be given too.
function M.wcs_to(s, ws, maxsz)
    if s == nil then
        s = ''
    end
    if type(s) ~= 'string' then
        return s
    end

    if ffi.istype(ws, PWCS_ctype) then
        --pointer: size unknown, maxsz must be given.
        assert(maxsz, 'max size missing')
    else
        --WCHAR[?] or WCHAR[n]: size known, check maxsz against it.
        --NOTE: unfortunately we can't test generically for WCHAR[n] with what ffi provides.
        --so we'll just assume that any cdata that's not a WCHAR* is a WCHAR[n] or WCHAR[?]
        --for which sizeof returns the correct value.
        local wsz = ffi.sizeof(ws) / 2
        maxsz = math.min(maxsz or wsz, wsz)
    end

    local sz = checknz(MB2WC(CP, MB, s, #s + 1, nil, 0))
    if sz > maxsz then
        error('string too long. max chars: ' .. (ffi.sizeof(ws) / 2 - 1))
    end

    checknz(MB2WC(M.CP_UTF8, 0, s, #s + 1, ws, ffi.sizeof(ws)))
end

function M.MultiByteToWideChar(s)
	return M.wcs(s)
end

function M.WideCharToMultiByte(ws)
	return M.mbs(ws)
end

function M.convert(s, cpFrom, cpTo)
    if type(s) ~= 'string' then
        return s
    end
    local sz = #s + 1 --assume 1 byte per character + null terminator
    local buf = WCS_ctype(sz)
    sz = MB2WC(cpFrom, MB, s, #s + 1, buf, sz)
    if sz == 0 then
        if util.GetLastError() ~= ERROR_INSUFFICIENT_BUFFER then
            checknz(0)
        end
        sz = checknz(MB2WC(cpFrom, MB, s, #s + 1, nil, 0))
        buf = WCS_ctype(sz)
        sz = checknz(MB2WC(cpFrom, MB, s, #s + 1, buf, sz))
    end

    sz = checknz(WC2MB(cpTo, WC, buf, -1, nil, 0, nil, nil))
    buf = MBS_ctype(sz)
    checknz(WC2MB(cpTo, WC, buf, -1, buf, sz, nil, nil))
    return ffi.string(buf, sz - 1) --sz includes null terminator
end

return M
