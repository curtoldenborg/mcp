
block-level on error undo, throw.

using web.api.graphql.StringConstant.

class web.api.graphql.StringConstant abstract:
    // Control characters
    // Tab - octal 011
    define static public property TAB   as character no-undo initial '~t':u    get.
    // Carriage return - octal 015
    define static public property CR    as character no-undo initial '~r':u    get.
    // Line feed / new line - octal 012
    define static public property LF    as character no-undo initial '~n':u    get.
    define static public property CRLF  as character no-undo initial '~r~n':u  get.
    // Escape - octal 033
    define static public property ESC   as character no-undo initial '~E':u    get.
    // Backspace - octal 010
    define static public property BACK  as character no-undo initial '~b':u    get.
    // Form feed - octal 014
    define static public property FF    as character no-undo initial '~f':u    get.
    // Unit Separator - octal 037
    define static public property US    as character no-undo get. private set.     

    // Escaped strings
    define static public property TILDE         as character no-undo initial '~~':u    get.
    define static public property SEMICOLON     as character no-undo initial '~;':u    get.
    define static public property SINGLE_QUOTE  as character no-undo initial '~'':u    get.
    define static public property DOUBLE_QUOTE  as character no-undo initial '~"':u    get.
    define static public property BACKSLASH     as character no-undo initial '~\':u    get.
    define static public property CURLY_OPEN    as character no-undo initial '~{':u    get.
    define static public property CURLY_CLOSE   as character no-undo initial '~}':u    get.
    define static public property PAREN_OPEN    as character no-undo initial '(':u    get.
    define static public property PAREN_CLOSE   as character no-undo initial ')':u    get.
    define static public property UNICODE_ESC   as character no-undo get. private set.
    define static public property EMPTY as character no-undo initial '':u get.
    define static public property SPACE as character no-undo initial ' ':u get.
    define static public property UNKNOWN as character no-undo initial ? get.
    
    /* Static constructor */
    constructor static StringConstant():
        // this MUST be lower-case "u" (ASC dec 117 / hex 75)
        assign StringConstant:UNICODE_ESC = StringConstant:TILDE + 'u':u.
        // ascii description is unit separater.  Can be used as a delimiter. 
        assign StringConstant:US = chr(31).
    end constructor.
    
end class.
