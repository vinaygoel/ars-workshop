FROM continuumio/anaconda:latest

MAINTAINER Vinay Goel <vinaygo@gmail.com>

RUN apt-get update && apt-get install -y \
    gcc

RUN conda install -y \
    nltk \
    Pillow \
    networkx \
    matplotlib \
    seaborn \
    basemap \
    jupyter

RUN pip install \
    surt \
    warc \
    lda \
    python-geoip \
    python-geoip-geolite2 \
    wordcloud

RUN python -c "import nltk; nltk.download('stopwords', halt_on_error=False)";

EXPOSE 8888

CMD ["jupyter","notebook", "--ip='*'", "--port=8888", "--no-browser"]
