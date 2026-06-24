FROM gcr.io/distroless/cc-debian12:nonroot AS runtime
COPY --chown=nonroot:nonroot fixfolder.sh /usr/local/bin/fixfolder
ENTRYPOINT ["fixfolder"]
