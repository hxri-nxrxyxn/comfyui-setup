FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-devel

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    git-lfs \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir "triton>=3.0.0,<3.3.0" GitPython

RUN git clone https://github.com/gameblabla/SageAttention2.git /tmp/sageattention \
    && cd /tmp/sageattention \
    && sed -i 's/^compute_capabilities = set()$/compute_capabilities = {"7.5"}/' setup.py \
    && sed -i '/^device_count = torch.cuda.device_count()/,/^    compute_capabilities.add/d' setup.py \
    && python setup.py install \
    && rm -rf /tmp/sageattention

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8188

ENTRYPOINT ["/entrypoint.sh"]
CMD ["sh", "-c", "python main.py ${CLI_ARGS}"]
