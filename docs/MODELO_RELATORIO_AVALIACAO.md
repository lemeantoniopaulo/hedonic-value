# Modelo R Markdown de relatório de avaliação

O pacote adota R Markdown como formato canônico de relatório. Quarto não faz parte da primeira implementação.

O template organiza identificação, pesquisa de mercado, modelo estatístico, diagnósticos, evidências pendentes, estado da avaliação e conclusão profissional.

A função hv_render_report() apenas delega a renderização a rmarkdown::render(). Ela não decide se um modelo é adequado, não calcula grau de fundamentação e não emite laudo.

A ausência de pendências informadas não é interpretada como conformidade.
