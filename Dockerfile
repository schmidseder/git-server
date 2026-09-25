FROM alpine:latest

# Explanation of the sed command:
# Alpine/BusyBox creates passwordless users with a locked (!) password.
# Replace ! with * so SSH public-key authentication remains possible.
RUN apk add --no-cache openssh git \
    && git config --system init.defaultBranch main \
    && adduser -D -s /usr/bin/git-shell git \
    && sed -i 's/^git:!:/git:*:/' /etc/shadow \
    && mkdir -p /home/git/.ssh /repos \
    && chown -R git:git /home/git /repos \
    && chmod 700 /home/git/.ssh


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

CMD ["/entrypoint.sh"]
