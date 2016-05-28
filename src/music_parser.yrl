Nonterminals terms term notes chord c_note.
Terminals lambda left_paren right_paren dot
	  variable note l_bracket r_bracket
	  l_chevron r_chevron.
Rootsymbol terms.

terms ->  term  notes : {app, '$1', '$2'}.

% sequence of notes
notes -> note notes : {notes, {note, extract_token('$1')}, '$2'}.
notes -> l_bracket chord r_bracket notes : {notes, '$2', '$4'}.

% single note
notes -> note : {note, extract_token('$1')}.

% notes in parentheses
notes -> left_paren notes right_paren : '$2'.

% chords are in brackets
notes -> l_bracket chord r_bracket : '$2'.

chord -> c_note c_note c_note : {chord, '$1', '$2', '$3'}.

c_note -> note : {note, extract_token('$1')}.

%sequences are in chevrons
notes -> l_chevron notes r_chevron : {sequence, '$2'}.

% variable
term -> variable : {variable, extract_token('$1')}.

% application
term -> left_paren term term right_paren : {app, '$2', '$3'}.

% lambda term
term -> lambda variable dot term: {lambda, extract_token('$2'), '$4'}.

% term in parentheses
term -> left_paren term right_paren : '$2'.

Erlang code.

extract_token({_Token, _Line, Value}) -> Value.

% :yecc.file './src/music_parser.yrl'
% c "./src/music_parser.erl"