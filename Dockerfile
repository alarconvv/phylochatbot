FROM rocker/shiny:latest
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev libssl-dev libxml2-dev git \
    && rm -rf /var/lib/apt/lists/*
RUN Rscript -e "install.packages('pak', repos='https://r-lib.github.io/p/pak/stable')"
RUN Rscript -e "pak::pkg_install(c('bslib', 'shinychat', 'ellmer', 'ragnar', 'duckdb'))"
RUN rm -rf /srv/shiny-server/*
COPY app.R /srv/shiny-server/app.R
COPY phyloSource.duckdb /srv/shiny-server/phyloSource.duckdb
RUN chown -R shiny:shiny /srv/shiny-server
EXPOSE 3838
CMD ["/usr/bin/shiny-server"]
