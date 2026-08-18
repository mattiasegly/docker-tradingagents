FROM python:alpine AS builder

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
	PYTHONUNBUFFERED="yes"

RUN apk add --no-cache git

WORKDIR /source
RUN git clone --depth 1 \
	https://github.com/TauricResearch/TradingAgents.git .
RUN pip install --no-cache-dir .

FROM python:alpine

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
        PYTHONUNBUFFERED="yes"

RUN adduser -D appuser && \
	install -d -o appuser -g appuser -m 0755 /home/appuser/.tradingagents

USER appuser
WORKDIR /home/appuser/app
COPY --from=builder --chown=appuser:appuser /source .

ENTRYPOINT ["tradingagents"]
