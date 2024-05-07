#!/usr/bin/env python3
"""
find_sequence_in_assemblies.py

This script searches for a specified DNA sequence in a set of bacterial assembly files (in FASTA format).
If the sequence is found in an assembly, the contig containing the sequence is extracted and saved in a new directory
with the original file name appended with '_contig'.

Usage:
    python find_sequence_in_assemblies.py -d <assemblies_directory> -s <sequence_file.fasta> -o <output_directory>

Author: Carlos Serna
"""

import os
import argparse
import logging
from Bio import SeqIO
from Bio.Seq import Seq

def setup_logging():
    """Setup basic logging configuration."""
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def read_sequence(file_path):
    """Read sequence from a FASTA file."""
    try:
        return SeqIO.read(file_path, "fasta").seq
    except Exception as e:
        logging.error(f"Failed to read sequence from {file_path}: {e}")
        raise

def search_sequence(assemblies_dir, sequence, reverse_complement, output_dir):
    """
    Searches for a sequence and its reverse complement within assembly files and extracts the containing contig.

    :param assemblies_dir: Directory containing FASTA assembly files.
    :param sequence: Sequence to search for.
    :param reverse_complement: Reverse complement of the sequence to search for.
    :param output_dir: Directory where results will be saved.
    """
    if not os.path.exists(output_dir):
        logging.info(f"Creating output directory at {output_dir}")
        os.makedirs(output_dir)

    for file in os.listdir(assemblies_dir):
        if file.endswith(".fasta"):
            full_path = os.path.join(assemblies_dir, file)
            try:
                for record in SeqIO.parse(full_path, "fasta"):
                    if sequence in record.seq or reverse_complement in record.seq:
                        output_file = os.path.splitext(file)[0] + "_contig.fasta"
                        with open(os.path.join(output_dir, output_file), "w") as output_handle:
                            SeqIO.write(record, output_handle, "fasta")
                        logging.info(f"Contig extracted to {output_file}")
                        break
            except Exception as e:
                logging.error(f"Error processing file {full_path}: {e}")

def main():
    parser = argparse.ArgumentParser(description="Search for a DNA sequence in bacterial assembly files and extract the contig containing it.")
    parser.add_argument("-d", "--directory", required=True, help="Directory containing FASTA assembly files.")
    parser.add_argument("-s", "--sequence", required=True, help="FASTA file of the sequence to search for.")
    parser.add_argument("-o", "--output", required=True, help="Output directory for extracted contigs.")
    args = parser.parse_args()

    setup_logging()

    logging.info("Reading target sequence and its reverse complement.")
    target_sequence = read_sequence(args.sequence)
    reverse_complement = target_sequence.reverse_complement()

    logging.info("Starting sequence search in assembly files.")
    search_sequence(args.directory, target_sequence, reverse_complement, args.output)

if __name__ == "__main__":
    main()