# Should maybe make a supervisor here or in LambdaMusic
port = Port.open({:spawn, "pacat -p --channels=1 --rate=16000 --format=s16be"}, [:binary])

#expr = "(\\x.x)A"

#expr = "(\\x.\\y.\\z.\\w.(((w y) z)x))ABCD"

expr = "(\\a.\\b.\\c.((((((a a) b) b) c) c) b))[CEA][DAG][EFG]"

# NOTE: fix should only be applied to sequences or functions!
#Taken from the paper "Lambda Calculus and Music Calculi"
#fix = "\\f.(\\x.(f(x x))(\\x.(f(x x)))"
#inter = "(#{fix})(\\a.\\b.(a b))"
#mult = "\\a.\\b.(#{Loop} \\c.((c b)a))"



LambdaMusic.compute(expr)
|> PCM_Play.play(port)
