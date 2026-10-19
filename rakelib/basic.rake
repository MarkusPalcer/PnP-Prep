
def build_raw(latex_path, aux_dir)
  job_name = Pathname(latex_path).basename.sub_ext('').to_s

  Dir.chdir(Pathname(latex_path).dirname.to_s) do 
    system(
        "latexmk",
        "-pdf",
        "-interaction=nonstopmode",
        "-shell-escape",
        "-synctex=0",
        "-outdir=#{aux_dir.to_s}",
        "-jobname=#{job_name}",
        latex_path,
        out: ENV['RAKE_VERBOSE'] ? $stdout : File::NULL,
        err: ENV['RAKE_VERBOSE'] ? $stderr : File::NULL
    )
  end
end

def build(latex_path, target, verbose: true)
  aux_dir       = Pathname("/tmp")
  target_dir    = target.dirname
  target_log    = target.sub_ext(".log")
  job_name      = Pathname(latex_path).basename.sub_ext('').to_s
  generated_pdf = aux_dir.join("#{job_name}.pdf")
  generated_log = aux_dir.join("#{job_name}.log")

  FileUtils.rm_rf target
  FileUtils.rm_rf target_log

  puts "Building #{latex_path}..." if verbose

  if build_raw latex_path, aux_dir
      FileUtils.cp(generated_pdf, target)
      puts "#{target}: Success" if verbose
      return target
  else
      FileUtils.cp(generated_log, target_log) if generated_log.exist?
      raise "#{target}: Failure"
  end

  FileUtils.rm_rf Dir[aux_dir.join("#{job_name}.*")]
end