FROM public.ecr.aws/lambda/python:3.13-arm64 AS production

COPY --from=ghcr.io/astral-sh/uv:0.11.2 /uv /bin/uv

WORKDIR ${LAMBDA_TASK_ROOT}

# Install dependencies
COPY uv.lock pyproject.toml ./
RUN uv export --frozen --no-emit-workspace --no-dev --no-editable -o requirements.txt && \
    uv pip install --system -r requirements.txt

ENV PYTHONUNBUFFERED=1

# Copy application code
COPY . ${LAMBDA_TASK_ROOT}

# Test stage
FROM production AS test

RUN uv export --frozen --no-emit-workspace --only-group dev --no-editable -o requirements-dev.txt && \
    uv pip install --system -r requirements-dev.txt

COPY tests/ ${LAMBDA_TASK_ROOT}/tests/

ENTRYPOINT ["python", "-m", "pytest"]
