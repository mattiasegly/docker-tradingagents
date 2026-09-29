FROM python:slim AS builder

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
	PYTHONUNBUFFERED="yes"

RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /source
RUN git clone --depth 1 \
	https://github.com/TauricResearch/TradingAgents.git .
RUN pip install --no-cache-dir .

FROM python:slim

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
	PYTHONUNBUFFERED="yes"

RUN useradd --create-home appuser && \
	install -d -o appuser -g appuser -m 0755 /home/appuser/.tradingagents

USER appuser
WORKDIR /home/appuser/app
COPY --from=builder --chown=appuser:appuser /source .

ENTRYPOINT ["tradingagents"]
