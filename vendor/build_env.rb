
def vendor_build_env
  # Each of the following environment variables should be set,
  # preferably by an automated tool like Qt::Commander::Creator::Toolchain#env
  [
    'ANDROID_NDK_ROOT', # eg. "/home/user/android/android-ndk-r9d"
    'TOOLCHAIN_PATH',   # eg. "/home/user/android/android-ndk-r9d/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86_64/bin"
    'TOOLCHAIN_NAME',   # eg. "arm-linux-androideabi-4.8"
    'TOOLCHAIN_HOST',   # eg. "arm-linux-androideabi"
    'TOOLCHAIN_ARCH',   # eg. "arm"
  ].each { |x| raise "Please set the #{x} environment variable" unless ENV[x] }
  
  host = ENV['TOOLCHAIN_HOST']
  arch = ENV['TOOLCHAIN_ARCH']
  ndk_root = ENV['ANDROID_NDK_ROOT']
  toolpath = ENV['TOOLCHAIN_PATH']
  
  sysroot = "#{ndk_root}/platforms/android-9/arch-#{arch}"
  prefix_dir = File.join(File.dirname(__FILE__),'prefix/'+ENV['TOOLCHAIN_NAME'])
  
  system "mkdir -p #{prefix_dir}"
  
  _CPP    = "#{host}-cpp"
  _CC     = "#{host}-gcc"
  _CXX    = "#{host}-g++"
  _LD     = "#{host}-ld"
  _AS     = "#{host}-as"
  _AR     = "#{host}-ar"
  _RANLIB = "#{host}-ranlib"
  
  _CFLAGS   = "--sysroot=#{sysroot}"
  _CPPFLAGS = "--sysroot=#{sysroot}"
  _CXXFLAGS = "--sysroot=#{sysroot}"
  _LDFLAGS  = ""
  _LIBS     = "-lc -lgcc -ldl"
  
  
  # Construct load flags from global variables and library-specific option hash
  define_method :environment do |opts|
    opts ||= {}
    env = opts.fetch :env, {}
    
    env.each_pair.map { |k,v| "export #{k}='#{v}' && " }.join
  end
  
  # Construct load flags from global variables and library-specific option hash
  define_method :configure_flags do |opts|
    opts ||= {}
    
    case opts[:APP_STL]
    when :stlport_static
      case arch
      when 'arm'
        (opts[:LDFLAGS]  ||= "") << " -L#{ndk_root}/sources/cxx-stl/stlport/libs/armeabi"
      when 'x86'
        (opts[:LDFLAGS]  ||= "") << " -L#{ndk_root}/sources/cxx-stl/stlport/libs/x86"
      when 'mips'
        (opts[:LDFLAGS]  ||= "") << " -L#{ndk_root}/sources/cxx-stl/stlport/libs/mips"
      end
      (opts[:CFLAGS]   ||= "") << " -I#{ndk_root}/sources/cxx-stl/stlport/stlport"
      (opts[:CPPFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/stlport/stlport"
      (opts[:CXXFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/stlport/stlport"
      (opts[:LIBS]     ||= "") << " -lstlport_static"
    when :stlport_gnu_48
      case arch
      when 'arm'
        (opts[:LDFLAGS]  ||= "") << " -L#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/armeabi"
        (opts[:CFLAGS]   ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/armeabi/include"
        (opts[:CPPFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/armeabi/include"
        (opts[:CXXFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/armeabi/include"
      when 'x86'
        (opts[:LDFLAGS]  ||= "") << " -L#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/x86"
        (opts[:CFLAGS]   ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/x86/include"
        (opts[:CPPFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/x86/include"
        (opts[:CXXFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/x86/include"
      when 'mips'
        (opts[:LDFLAGS]  ||= "") << " -L#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/mips"
        (opts[:CFLAGS]   ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/mips/include"
        (opts[:CPPFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/mips/include"
        (opts[:CXXFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/libs/mips/include"
      end
      (opts[:CFLAGS]   ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/include"
      (opts[:CPPFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/include"
      (opts[:CXXFLAGS] ||= "") << " -I#{ndk_root}/sources/cxx-stl/gnu-libstdc++/4.8/include"
      (opts[:LIBS]     ||= "") << " -lgnustl_shared"
    end
    
    [
      "CPP=#{_CPP}",
      "CC=#{_CC}",
      "CXX=#{_CXX}",
      "LD=#{_LD}",
      "AS=#{_AS}",
      "AR=#{_AR}",
      "RANLIB=#{_RANLIB}",
      
      "CFLAGS='#{_CFLAGS} #{opts[:CFLAGS]} -I#{prefix_dir}/include'",
      "CPPFLAGS='#{_CPPFLAGS} #{opts[:CPPFLAGS]} -I#{prefix_dir}/include'",
      "CXXFLAGS='#{_CXXFLAGS} #{opts[:CXXFLAGS]} -I#{prefix_dir}/include'",
      "LDFLAGS='#{_LDFLAGS} #{opts[:LDFLAGS]} -L#{prefix_dir}/lib'",
      "LIBS='#{_LIBS} #{opts[:LIBS]}'",
      "PKG_CONFIG_PATH='#{prefix_dir}/lib/pkgconfig'",
      
      " --host=#{host}",
      " --prefix=#{prefix_dir}",
      
      opts.fetch(:other, ''),
    ].join(' ')
  end
  
end
