iFROM nvidia/cuda:12.3.1-devel-ubuntu20.04

ENV CUDA_HOME /usr/local/cuda

# Install Python, pip, and git
RUN apt-get update && \
    apt-get install -y python3-pip python3-dev git && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Set FORCE_CUDA if necessary
ENV FORCE_CUDA=1

# Install PyTorch with CUDA support and other dependencies
RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113 \
    && pip install git+https://github.com/UX-Decoder/Segment-Everything-Everywhere-All-At-Once.git@package \
    && pip install git+https://github.com/facebookresearch/segment-anything.git \
    && pip install git+https://github.com/UX-Decoder/Semantic-SAM.git@package \
    && cd ops && sh make.sh && cd ..

# Run download_ckpt.sh to download the pretrained models
RUN sh download_ckpt.sh

# Make port 80 available to the world outside this container
EXPOSE 80

# Run demo_som.py when the container launches
CMD ["python", "./demo_som.py"]
