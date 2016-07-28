# LambdaMusic

A musical interpreter of lambda expressions. Input a lambda expression applied to a series of notes to get a simple PCM-generated tune! 

Still a work in progress!


## Installation

  1. Add lambda_music to your list of dependencies in mix.exs:
    ```elixir
        def deps do
          [{:lambda_music, "~> 0.0.1"}]
        end
    ```	

  2. Ensure lambda_music is started before your application:
   ```elixir
        def application do
          [applications: [:lambda_music]]
        end
    ```
## Usage
    Currently only works well in the command line using iex:
     LambdaMusic.compute("(\\x.\\y.\\z.((z x) y))[CGA]BD")
     (\x.\y.\z.((z x) y))[CGA]BD ->
     (\y.\z.((z)[CGA]y))(BD) ->
     (\z.((z)[CGA]B))D ->
     D[CGA]B
     "D[CGA]B"

    

  