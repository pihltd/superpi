workflow helloHaplotypeCaller {
  call haplotypeCaller
}

task haplotypeCaller {
  File GATK
  File RefFasta
  String sampleName
  File inputBAM
  File RefIndex
  File RefDict
  File bamIndex

  command{
    java -jar ${GATK} \
      -T HaplotypeCaller \
      -R ${RefFasta} \
      -I ${inputBAM} \
      -o ${sampleName}.raw.indels.snps.vcf
  }

  output {
    File rawVCF = "${sampleName}.raw.indels.snps.vcf"
  }
}
