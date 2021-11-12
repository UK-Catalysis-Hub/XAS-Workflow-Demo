#!/usr/bin/env nextflow

def helpMessage() {
  log.info """
       Usage:
        The command for running workflw is:
        nextflow run xas_main.nf --data_dir \$PWD/data/*.dat --outfile isles.dat

        Mandatory arguments:
         --query                       Query file count words
         --outfile                     Output file name
         --outdir                      Final output directory

        Optional arguments:
         --app                         Python executable
         --wordcount                   Python code to execute
         --help                        This usage statement.
        """
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}

println "Task 01 process files in $params.data_dir using $params.athena_task and output to file *.prj in $params.athena_dir"
println "Task 02.01 generate paths from $params.crystal_files using $params.feff_task and output to dirs in $params.outdir"
println "Task 02.02 fit paths to XAS spectra"

process runAthena{
  output:
    file "*.prj" into athena_prjs

  publishDir "$params.outdir/$params.athena_dir", mode: 'copy', overwrite: true

  script:
  """
  $params.app $params.athena_task '$params.data_dir' $params.athena_dir

  """
}

process runFEFF{
  output:
    file "*" into feff_paths

  publishDir "$params.outdir", mode: 'copy', overwrite: true
  script:
  """
  $params.app $params.feff_task '$params.crystal_files' 
  """
}

process runFit {
  input:
    file apf from athena_prjs.flatten()
    file "*" from feff_paths

  output:
    file "**.txt"	
    file "**.png"

  publishDir "$params.outdir", mode: 'copy', overwrite: true
  
  script:
  """
  $params.app $params.fit_task $params.ini_file $apf $params.athena_dir $params.gds_file $params.sp_file
  """ 
}
