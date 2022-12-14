defmodule Nqcc do
  @moduledoc """
  Documentation for Nqcc.
  """
  @commands %{
    "help" => "Prints this help (information about each flag)",
    "l" => "Prints to the screen the code generated by the lexer without creating any executable or file",
    "p" => "Prints to the screen the code generated by the parser without creating any executable or file",
    "s" => "Prints to the screen the code generated by the code generator without creating any executable or file",
    "q" => "Prints all the codes (sanitizer, lexer, parser and code generator) without creating any executable or file",
    " " => "Run the compile for create the executable without printing any code to the screen"
  }

  def main(args) do
    args
    |> parse_args
    |> process_args
  end

  def parse_args(args) do
    OptionParser.parse(args, switches: [help: :boolean, l: :boolean, p: :boolean, s: :boolean, q: :boolean])
  end

  defp process_args({[help: true], _, _}) do
    print_help_message()
  end

#LEXER PROCESS

  defp process_args({[l: true], [file_name], _})do
    compile_file_lexer(file_name)
  end

#PARSER PROCESS

  defp process_args({[p: true], [file_name], _})do
    compile_file_parser(file_name)
  end
  
#GENERATOR CODE PROCESS

  defp process_args({[s: true], [file_name], _})do
    compile_file_generator_code(file_name)
  end

#SANITIZER, LEXER, PARSER AND CODE GENERATOR

  defp process_args({[q: true], [file_name], _}) do
    compile_file_everything(file_name)
  end

  defp process_args({_, [file_name], _}) do
    compile_file(file_name)
  end

#COMPILE FILE

  defp compile_file(file_path) do
    assembly_path = String.replace_trailing(file_path, ".c", ".s")

    File.read!(file_path)
    |> Sanitizer.sanitize_source()
    |> Lexer.scan_words()
    |> Parser.parse_program()
    |> CodeGenerator.generate_code_compile()
    |> Linker.generate_binary(assembly_path)
  end

#LEXER COMPILE

  defp compile_file_lexer(file_path) do
    File.read!(file_path)
    |> Sanitizer.sanitize_source()
    |> Lexer.scan_words()
    |> IO.inspect(label: "\nLexer ouput")
  end

#PARSER COMPILE

  defp compile_file_parser(file_path) do
    File.read!(file_path)
    |> Sanitizer.sanitize_source()
    |> Lexer.scan_words()
    |> Parser.parse_program()
    |> IO.inspect(label: "\nParser ouput")
  end

#GENERATOR CODE COMPILE

  defp compile_file_generator_code(file_path)do
    File.read!(file_path)
    |> Sanitizer.sanitize_source()
    |> Lexer.scan_words()
    |> Parser.parse_program()
    |> CodeGenerator.generate_code()
  end

#SANITIZER, LEXER, PARSER AND CODE GENERATOR COMPILE

  defp compile_file_everything(file_path) do
    File.read!(file_path)
    |> Sanitizer.sanitize_source()
    |> IO.inspect(label: "\nSanitizer ouput")
    |> Lexer.scan_words()
    |> IO.inspect(label: "\nLexer ouput")
    |> Parser.parse_program()
    |> IO.inspect(label: "\nParser ouput")
    |> CodeGenerator.generate_code()
  end

  defp print_help_message do
    IO.puts("\n************************************************************************************************")
    IO.puts("\n 
 ---------   --------|-|   -----|   -----|       ---          ---       -----        |------
/  -----  \\  |   ---   |  / ----|  / ----|       \\  \\        /  /      / /|  |       |---  |
|  |   |  |  |  |   |  |  | |      | |            \\  \\      /  /       -- |  |           | |
|  |   |  |  |  |   |  |  | |      | |             \\  \\    /  /           |  |       |---  |
|  |   |  |  |   ---   |  \\ ----|  \\ ----|          \\  \\  /  /  --        |  |  --   |---  |
----   ----  --------| |   -----|   -----|           \\  --  /  |  |       |  | |  |      | |
                     | |                               ----     --        |  |  --   |---  |
                     | |                                                   --        |------
                     ----
                     \n")
    IO.puts("************************************************************************************************")

    IO.puts("\nnqcc --help file_name or nqcc --help\n")

    IO.puts("\nThe compiler supports following options:\n")

    @commands
    |> Enum.map(fn {command, description} -> IO.puts("  #{command} - #{description}") end)
  end
end