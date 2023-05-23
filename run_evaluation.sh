DATASET=pancreatic_islet
DATA_ROOT=/home/galkowskim/disk_data/data
EXPRESSION_PATH=/home/galkowskim/disk_data/data/GSE50244_TMM_NormLength.xlsx
HIC_PATH=~/disk_data/data/DFF064KIG2.cool
RESOLUTION=50000
COEXP_PERCENTILE=90.0
HIC_PERCENTILE=80.0
EMBEDDING_SIZE=16

DATASET0=${DATASET}_healthy
DATASET1=${DATASET}_diabetic

cd /home/galkowskim/Desktop/HiCoEx_research/src/link_prediction

for i in `seq 1 22`
do
  echo first_part_chromosome_${i}
  python matrix_factorization.py --data-root $DATA_ROOT --dataset $DATASET0 --chromatin-network observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --emb-size $EMBEDDING_SIZE --save-emb --task none
  python random_walk.py --data-root $DATA_ROOT --dataset $DATASET0 --chromatin-network observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --emb-size $EMBEDDING_SIZE --save-emb --task none
done

for i in `seq 1 22`
do
  echo second_part_chromosome_${i}
  python matrix_factorization.py --data-root $DATA_ROOT --dataset $DATASET1 --chromatin-network observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --emb-size $EMBEDDING_SIZE --save-emb --task none
  python random_walk.py --data-root $DATA_ROOT --dataset $DATASET1 --chromatin-network observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --emb-size $EMBEDDING_SIZE --save-emb --task none
done

# link prediction
for i in `seq 1 22`
do
  echo
  echo healthy_chromosome_${i}
  echo
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET0 --chr-src $i --chr-tgt $i --method random --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --coexp-thr $COEXP_PERCENTILE --classifier random --gpu --test --times 0 --seed 42
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET0 --chr-src $i --chr-tgt $i --method distance --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --aggregators hadamard --coexp-thr $COEXP_PERCENTILE --gpu --test --times 0 --seed 42
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET0 --chr-src $i --chr-tgt $i --method topological --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --aggregators avg l1 --coexp-thr $COEXP_PERCENTILE --gpu --test --times 0 --seed 42
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET0 --chr-src $i --chr-tgt $i --method svd --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --aggregators hadamard --coexp-thr $COEXP_PERCENTILE --gpu --test --times 0 --seed 42
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET0 --chr-src $i --chr-tgt $i --method node2vec --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --aggregators hadamard --coexp-thr $COEXP_PERCENTILE --gpu --test --times 0 --seed 42
done


for i in `seq 1 22`
do
  echo diabetic_chromosome_${i}
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET1 --chr-src $i --chr-tgt $i --method random --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --coexp-thr $COEXP_PERCENTILE --classifier random --gpu --test --times 0 --seed 42
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET1 --chr-src $i --chr-tgt $i --method distance --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --aggregators hadamard --coexp-thr $COEXP_PERCENTILE --gpu --test --times 0 --seed 42
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET1 --chr-src $i --chr-tgt $i --method topological --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --aggregators avg l1 --coexp-thr $COEXP_PERCENTILE --gpu --test --times 0 --seed 42
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET1 --chr-src $i --chr-tgt $i --method svd --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --aggregators hadamard --coexp-thr $COEXP_PERCENTILE --gpu --test --times 0 --seed 42
  python 01_link_prediction_chromosome.py --data-root $DATA_ROOT --dataset $DATASET1 --chr-src $i --chr-tgt $i --method node2vec --chromatin-network-name observed_${i}_${i}_${RESOLUTION}_${HIC_PERCENTILE} --aggregators hadamard --coexp-thr $COEXP_PERCENTILE --gpu --test --times 0 --seed 42
done
