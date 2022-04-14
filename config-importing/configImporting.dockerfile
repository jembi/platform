FROM node:erbium-alpine

ADD config.js .

ENTRYPOINT [ "node", "config.js" ]
