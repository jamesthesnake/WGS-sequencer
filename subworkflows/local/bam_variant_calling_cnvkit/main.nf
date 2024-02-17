//
// CNVKIT calling
//
// For all modules here:
// A when clause condition is defined in the conf/modules.config to determine if the module should be run

include { CNVKIT_BATCH } from '../../../modules/nf-core/cnvkit/batch/main'
include { CNVKIT_GENEMETRICS } from '../../../modules/nf-core/cnvkit/genemetrics/main'

workflow BAM_VARIANT_CALLING_CNVKIT {
    take:
    cram                // channel: [mandatory] meta, cram
    fasta               // channel: [mandatory] meta, fasta
    fasta_fai           // channel: [optional]  meta, fasta_fai
    targets             // channel: [mandatory] meta, bed
    reference           // channel: [optional]  meta, cnn

    main:
    versions = Channel.empty()
    generate_pon = false

    CNVKIT_BATCH(cram, fasta, fasta_fai, targets, reference, generate_pon)

    ch_genemetrics = CNVKIT_BATCH.out.cnr.join(CNVKIT_BATCH.out.cns).map{ meta, cnr, cns -> [meta, cnr, cns[2]]}
    CNVKIT_GENEMETRICS(ch_genemetrics)

    versions = versions.mix(CNVKIT_BATCH.out.versions)
    versions = versions.mix(CNVKIT_GENEMETRICS.out.versions)

    emit:
    versions // channel: [ versions.yml ]
}
