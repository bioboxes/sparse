#!/bin/bash

set -o errexit
set -o nounset

TASK=$1
CMD=$(fetch_task_from_taskfile.sh $TASKFILE $TASK)
CONTIGS=${OUTPUT}/contigs.fa

cd $(mktemp -d)

# Create shuffled fasta file from paired ends
# Not sure why this is necessary? Any input welcome
SHUFFLED_INPUT=reads.fa.gz
READS=$(biobox_args.sh 'select(has("fastq")) | .fastq | map(.value) | join(" ")')
cat ${READS} | shuffle.sh
	interleaved=true
	in=stdin.fq.gz
	out=${SHUFFLED_INPUT}


# Default sparse parameters
GAP_VALUE=15
LOAD_GRAPH=0
USE_PAIRED_END=0
PATH_COVERAGE_THRESHOLD=50
MEMORY_SIZE=$(kmercountexact.sh in=$SHUFFLED_INPUT peaks=stdout.txt 2> /dev/null \
	| grep "#genome_size" \
	| sed "s/#genome_size\t/15*/" \
	| bc)
DEFAULT=100000000

eval ${CMD}

SparseAssembler \
	g ${GAP_VALUE} \
	k ${KMER_SIZE} \
	GS $(( ${MEMORY_SIZE} > ${DEFAULT} ? ${MEMORY_SIZE} : ${DEFAULT})) \
	LD ${LOAD_GRAPH} \
	ResolveBranchesPE ${USE_PAIRED_END} \
	NodeCovTh ${NODE_COVERAGE_THRESHOLD} \
	EdgeCovTh ${EDGE_COVERAGE_THRESHOLD} \
	PathCovTh ${PATH_COVERAGE_THRESHOLD} \
	f ${SHUFFLED_INPUT}

mv Contigs.txt ${CONTIGS}

# This command writes yaml into the biobox.yaml until the EOF symbol is reached
cat << EOF > ${OUTPUT}/biobox.yaml
version: 0.9.0
arguments:
  - fasta:
    - id: contigs1
      value: Contigs.txt
      type: contigs
EOF
