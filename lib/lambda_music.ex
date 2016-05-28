defmodule LambdaMusic do
	@moduledoc """ 
	Computes the lambda encoding of a given musical score, then sends the computed
	notation to a PCM module for playback.
	"""
	require :music_lexer
	require :music_parser

	defmodule ParsingError do
		defexception message: "lambda-term parsing error"
	end
	
	@doc""" 
	Takes in a lambda expression and note sequence and computes it. 
	Lambda expressions should use \\ for lambda, for example \\x.x
	"""
	def compute(expr) when is_binary(expr) do
		expr = expr
		|> String.replace("λ", "\\")
		IO.puts(expr <> " ->")
		expr = String.to_char_list(expr)
		encode(expr)
	end
	
	defp encode(expr) do
		try do
			{:ok, tokens, _} = :music_lexer.string(expr)
			{:ok, ast} = :music_parser.parse(tokens)
			notes = beta(ast)
		  sequence = note_string(notes)
		  IO.puts(sequence)
		  sequence
		rescue
		   err in MatchError ->
			%MatchError{term: term} = err
			raise ParseError, inspect term
		end		
	end

	# note beta-redex
  defp beta({:app, {:lambda, x, y}, {:notes, head, tail}}) do
		lambda = {:lambda, x, y}
		bound = x
	  beta_redex = Tuple.append({:app, eval(lambda, head, bound)}, tail)
		str_redex = print_term(beta_redex)
		IO.puts(str_redex <> " ->")
		beta(beta_redex)
		#|> beta
		#beta(beta_redex, tail)
	end

	# non-note beta-redex
	defp beta({:app, {:lambda, x, y}, term2}) do
		beta_redex = eval({:lambda, x, y}, term2, x)
		beta_redex
	end

	# return var
	defp beta({:variable, variable}) do
		{:variable, variable}
	end

	# return note
	defp beta({:note, note}) do
      {:note, note}
	end

	# check for redexs in app then return 
	defp beta({:app, {:app, x, y}, term2}) do
		b_term1 = beta({:app, x, y})
		b_term2 = beta(term2)
		{:app, b_term1, b_term2}
	end
	
	#evaluates the Beta reduction by substituting the term with every occurence of a bound variable.
  defp eval({:lambda, x,  term}, z, bound) do
		beta_term =
		  cond do
		  (x == bound) -> eval(term, z, bound)
			true -> {:lambda, x, eval(term, z, bound)}
		end
		beta_term
	end
	
		
		#if (x == bound) do
		#	beta_term = eval(term, z, bound)
		#else
		#	beta_term = {:lambda, x, eval(term, z, bound)}
		#end
		#beta_term
	#end
	
	
	defp eval({:app, {term1, var}, {term2, var2}}, z, bound) do

		if (var == bound && var2 == bound) do
			{:app, z, z}
		else
			cond do
				(var == bound) -> {:app, z, {term2, var2}}
				(var2 == bound) -> {:app, {term1, var}, z}
				true -> {:app, {term1, var}, {term2, var2}}
			end
		end
  end

	defp eval({term, term1, term2,term3}, z, bound) do
		b_term1 = eval(term1, z, bound)
		b_term2 = eval(term2, z, bound)
		b_term3 = eval(term3, z, bound)
		{term, b_term1, b_term2, b_term3}
	end

	defp eval({term, term1, term2}, z, bound) do
		b_term1 = eval(term1, z, bound)
		b_term2 = eval(term2, z, bound)
		{term, b_term1, b_term2}
	end

	defp eval({term, var}, beta_var, bound)  do
		if (var == bound) do
			beta_var
		else
			{term, var}
		end		
	end
	
	@doc """
	Checks whether there are any free variables within the term.
	"""
	def no_free({:lambda, variable, term}) do
		if free?(term, variable) do
			alpha({:lambda, variable, term})
		else
			{:lambda, variable, term}
		end
	end
	
	def no_free({:app, term1, term2}) do
		cond do
			free?(term1) -> alpha(term1)
			free?(term2) -> alpha(term2)
			free?({:app, term1, term2}) -> alpha({:app, term1, term2})
			true -> {:app, term1, term2}
		end
	end
	
	def no_free({:notes, note, notes}) do
		{:notes, note, notes}
	end
	
	def no_free({:note, note}) do
		{:note, note}
	end
	
	def no_free({:variable, variable}) do
		{:variable, variable}
	end
	
	defp free?({:notes, _, _}, _variable) do
		false
	end
	
	defp free?({:note, _}, _variable) do
		false
	end
	
	defp free?({:variable, bound_variable}, variable) do
		if bound_variable == variable do
			true
		else
			false
		end
	end

	defp free?({:lambda, bound_var, term}) do
		if free?(term, bound_var) do
			true
		else
			false
		end																		
	end

	defp free?({:lambda, bound_var, term}, variable) do
		if variable == bound_var do
			true
		else
			free?(term, variable)
		end
	end

	defp free?({:app, term1, term2}) do
    cond do
			lambda?(term1) -> free?(term1)
			lambda?(term2) -> free?(term2)
			true -> {:app, term1, term2}
		end
	end
	
	defp free?({:app, term1, term2}, variable) do
		cond do
		  free?(term1, variable) -> true
		  free?(term2, variable) -> true
			true -> false
		end
	end

	# check if the first term in an application is a lambda
	defp lambda?({:lambda, _, _}), do: true
	defp lambda?({_terms, _, _, _}), do: false
  defp lambda?({_terms, _, _}), do: false
	defp lambda?({_term, _}), do: false
	
	defp alpha({:lambda, bound_var, term}) do
		#	String.to_integer(to_string(bound_var))
		#alpha_var = to_char_list(String.to_integer(to_string(bound_var) + 1))
	  #alpha_term = alpha(term, alpha_var)
	  # {:lambda, alpha_var, alpha_term}	

	end

	defp alpha({:lambda, _var, term}, alpha_var) do
		alpha_term = alpha(term, alpha_var)
		{:lambda, alpha_var, alpha_term}
	end

	defp alpha({:app, term1, term2}, alpha_var) do
		a_term1 = alpha(term1, alpha_var)
		a_term2 = alpha(term2, alpha_var)
		{:app, a_term1, a_term2}
	end
	
	defp alpha({:notes, note, notes}, _alpha_var) do
		{:notes, note, notes}
	end
	
	defp alpha({:note, note}, _alpha_var) do
		{:note, note}
	end
	
	defp alpha({:variable, _}, alpha_var) do
		{:variable, alpha_var} 
	end

	# converts notes into a string readable for PCM_Play
	def note_string({:chord, note1, note2, note3}) do
			"[" <> note_string(note1) <> note_string(note2) <> note_string(note3) <> "]"		
	end
	
  def note_string({_term, {:note, note}, term}) do
		  to_string(note) <> note_string(term)
	end
	
	def note_string({_term, term1, term2}) do
		note_string(term1) <> note_string(term2)
	end

	def note_string({:note, note}) do
    to_string(note)
	end

  @doc """
	Takes in a term and converts it into a printable string
	"""
	def print_term({_term, var}) do
		to_string(var)
	end

	def print_term({:chord, note1, note2, note3}) do
		print_term(note1) <> print_term(note2) <> print_term(note3)
	end

	def print_term({term, term1, term2}) when (term == :lambda) do
		"\\#{to_string(term1)}." <> print_term(term2)
	end
	
	def print_term({_term, term1, term2}) do
		cond do
			lambda?(term1) -> "(" <> print_term(term1) <> ")" <> print_term(term2)
			chord?(term2) -> "(" <> print_term(term1) <> ")" <> "[" <> print_term(term2) <> "]"
			true -> "(" <> print_term(term1) <> print_term(term2) <> ")" 
		end
	end

	#checks to see if the second term in application is a chord
	defp chord?({:chord, _, _, _}), do: true
	defp chord?({_term, _, _}), do: false
	defp chord?({_term, _}), do: false
end
