# Modelo R Markdown de relatório de avaliação

R Markdown é o formato canônico do pacote. Quarto não faz parte da primeira implementação.

O template organiza:

1. identificação e finalidade;
2. pesquisa de mercado;
3. modelo estatístico;
4. diagnósticos;
5. evidências pendentes;
6. estado da avaliação;
7. conclusão profissional.

A função hv_render_report() apenas delega a renderização a rmarkdown::render(). Ela não decide se o modelo é adequado, não calcula grau de fundamentação e não emite laudo.

A ausência de pendências informadas não equivale a conformidade normativa.
