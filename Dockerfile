FROM fenicsproject/test-env:mpich

# install the notebook package
RUN apt-get update && \
	apt-get install python3-pip -y
RUN pip3 install --no-cache --upgrade pip && \
    pip3 install --no-cache notebook

# create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}
ENV PETSC_ARCH "linux-gnu-real-32"
RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# Install python components
RUN pip3 install git+https://github.com/FEniCS/basix.git --upgrade && \
	pip3 install git+https://github.com/FEniCS/ufl.git --upgrade && \
	pip3 install git+https://github.com/FEniCS/ffcx.git --upgrade && \
	rm -rf /usr/local/include/dolfin /usr/local/include/dolfin.h

# Install progress-bar
RUN pip3 install tqdm

# Build C++ layer
RUN	 git clone https://github.com/FEniCS/dolfinx.git && \
	 cd dolfinx/ && \
	 mkdir -p build && \
	 cd build && \
	 cmake -G Ninja -DCMAKE_BUILD_TYPE=Relase ../cpp/ && \
	 ninja -j3 install

# Build Python layer
RUN cd dolfinx/python && \
	pip3 -v install .

# Install meshio
RUN export HDF5_MPI="ON" && \
    export CC=mpicc && \
    export HDF5_DIR="/usr/lib/x86_64-linux-gnu/hdf5/mpich/" && \
    pip3 install --no-cache-dir --no-binary=h5py h5py meshio


WORKDIR ${HOME}
COPY . ${HOME}
USER ${USER}
