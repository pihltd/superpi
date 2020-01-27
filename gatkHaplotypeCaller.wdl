workflow helloHaplotypeCaller {
  call haplotypeCaller
}

task haplotypeCaller {
  String GATK
  File RefFasta
  String sampleName
  File inputBAM
  File RefIndex
  File RefDict
  File bamIndex
  String resDir

  command{
    ${GATK} HaplotypeCaller \
      -R ${RefFasta} \
      -I ${inputBAM} \
      -O ${resDir}${sampleName}.raw.indels.snps.vcf
  }

  output {
    File rawVCF = "${resDir}${sampleName}.raw.indels.snps.vcf"
  }
}
