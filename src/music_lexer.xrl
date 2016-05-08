Definitions.

NOTE = [A-G]?

Rules.

\\	: {token, {lambda, TokenLine}}.
\(	: {token, {left_paren, TokenLine}}.
\)	: {token, {right_paren, TokenLine}}.
\. 	: {token, {dot, TokenLine}}.
\[	: {token, {l_bracket, TokenLine}}.
\] 	: {token, {r_bracket, TokenLine}}.
\<	: {token, {l_chevron, TokenLine}}.
\>	: {token, {r_chevron, TokenLine}}.
{NOTE} : {token, {note, TokenLine, TokenChars}}.
[a-z]	: {token, {variable, TokenLine, TokenChars}}.
[\s\t\r\n] : skip_token.

Erlang code.

% :leex.file 'music_lexer.xrl'
% c "music_lexer.erl"
