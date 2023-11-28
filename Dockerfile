FROM node:20

RUN corepack enable pnpm

RUN apt install -y unzip

ADD https://bun.sh/install /install-bun.bash
RUN bash install-bun.bash
ENV PATH "${PATH}:/root/.bun/bin"

ADD https://github.com/sharkdp/hyperfine/releases/download/v1.18.0/hyperfine-v1.18.0-x86_64-unknown-linux-gnu.tar.gz /hyperfine.tar.gz
RUN mkdir -p /hyperfine
RUN tar xzf /hyperfine.tar.gz --directory=/hyperfine
ENV PATH "${PATH}:/hyperfine/hyperfine-v1.18.0-x86_64-unknown-linux-gnu"

RUN mkdir /pnpm-bin
RUN pnpm config --global set global-bin-dir /pnpm-bin
ENV PATH "${PATH}:/pnpm-bin"
RUN pnpm install --global verdaccio

RUN mkdir /workspace
COPY package.json /workspace/package.json
COPY .npmrc /workspace/.npmrc
COPY bunfig.toml /workspace/bunfig.toml
COPY init-verdaccio.bash /workspace/init-verdaccio.bash
COPY benchmark.bash /workspace/benchmark.bash
WORKDIR /workspace
RUN /workspace/init-verdaccio.bash
ENTRYPOINT ["/workspace/benchmark.bash"]
