DATASET=pancreatic_islet
DATA_ROOT=/home/galkowskim/disk_data/data
EXPRESSION_PATH=/home/galkowskim/disk_data/data/GSE50244_TMM_NormLength.xlsx
HIC_PATH=~/disk_data/data/DFF064KIG2.cool
RESOLUTION=50000
COEXP_PERCENTILE=90.0
HIC_PERCENTILE=80.0

mkdir -p ~/disk_data/data/${DATASET}

cd /home/galkowskim/Desktop/HiCoEx_research/src/data_preprocessing
python3 01_gene_expression_islet.py --input $EXPRESSION_PATH --dataset $DATASET

DATASET0=${DATASET}_healthy
python3 02_hic_islet.py --input $HIC_PATH --dataset $DATASET0 --resolution $RESOLUTION --window $RESOLUTION

cd ${DATA_ROOT}
DATASET1=${DATASET}_diabetic
mkdir ${DATASET1}
mkdir ${DATASET0}/hic_raw
mkdir ${DATASET1}/hic_raw
cp -r ${DATASET}/hic_raw/* ./${DATASET1}/hic_raw/
cp -r ${DATASET}/hic_raw/* ./${DATASET0}/hic_raw/

cd /home/galkowskim/Desktop/HiCoEx_research/src/network_construction
python 01_compute_coexpression.py --data-root $DATA_ROOT --dataset $DATASET0 --save-plot --save-coexp
python3 02_coexpression_network.py --data-root $DATA_ROOT --dataset $DATASET0 --perc-intra $COEXP_PERCENTILE --save-matrix --save-plot
python3 03_hic_gene_selection.py --data-root $DATA_ROOT --dataset $DATASET0 --type observed --resolution $RESOLUTION --save-matrix --save-plot
python3 04_chromatin_network.py --data-root $DATA_ROOT --dataset $DATASET0 --type observed --resolution $RESOLUTION --type-inter observed --resolution-inter $RESOLUTION --perc-intra $HIC_PERCENTILE --save-matrix --save-plot

echo "BEFORE 4th SCRIPT"
python3 01_compute_coexpression.py --data-root $DATA_ROOT --dataset $DATASET1 --save-plot --save-coexp
python3 02_coexpression_network.py --data-root $DATA_ROOT --dataset $DATASET1 --perc-intra $COEXP_PERCENTILE --save-matrix --save-plot
python3 03_hic_gene_selection.py --data-root $DATA_ROOT --dataset $DATASET1 --type observed --resolution $RESOLUTION --save-matrix --save-plot
python3 04_chromatin_network.py --data-root $DATA_ROOT --dataset $DATASET1 --type observed --resolution $RESOLUTION --type-inter observed --resolution-inter $RESOLUTION --perc-intra $HIC_PERCENTILE --save-matrix --save-plot