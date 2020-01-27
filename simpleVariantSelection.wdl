workflow SimpleVariantSelection {
  String gatk
  File refFasta
  File refIndex
  File refDict
  String name
  String resDir

  call haplotypeCaller {
    input:
      sampleName = name,
      RefFasta = refFasta,
      GATK = gatk,
      RefIndex = refIndex,
      RefDict = refDict,
      ResDir = resDir
  }
  call select as selectSNPs {
    input:
      sampleName = name,
      RefFasta = refFasta,
      GATK = gatk,
      RefIndex = refIndex,
      RefDict = refDict,
      type="SNP",
      rawVCF=haplotypeCaller.rawVCF,
      ResDir = resDir
    }
  call select as selectIndels {
    input:
      sampleName = name,
      RefFasta = refFasta,
      GATK = gatk,
      RefIndex = refIndex,
      RefDict = refDict,
      type="INDEL",
      rawVCF=haplotypeCaller.rawVCF,
      ResDir = resDir
    }
}

task haplotypeCaller {
  String GATK
  File RefFasta
  File RefIndex
  File RefDict
  String sampleName
  File inputBAM
  File bamIndex
  String ResDir
  command {
    ${GATK} HaplotypeCaller \
        -R ${RefFasta} \
        -I ${inputBAM} \
        -O ${ResDir}${sampleName}.raw.indels.snps.vcf
  }
  output {
    File rawVCF = "${ResDir}${sampleName}.raw.indels.snps.vcf"
  }
}

task select {
  String GATK
  File RefFasta
  File RefDict
  File RefIndex
  String sampleName
  String type
  String rawVCF
  String ResDir

  command {
    ${GATK} SelectVariants \
    -R ${RefFasta} \
    -V ${rawVCF} \
    --select-type-to-include ${type} \
    -O ${ResDir}${sampleName}_raw.${type}.vcf
  }
  output {
    File rawSubset = "${ResDir}${sampleName}_raw.${type}.vcf"
  }
}
