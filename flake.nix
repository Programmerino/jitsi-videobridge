{
  description = "Jitsi";

  nixConfig.bash-prompt = "\[nix-develop\]$ ";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  inputs.nur.url = github:nix-community/NUR;

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils, nur}:
    flake-utils.lib.eachSystem(["x86_64-linux" "aarch64-linux"]) (system:
      let
        mavenix-src = fetchTarball { url = "https://github.com/nix-community/mavenix/tarball/v2.3.3"; sha256 = "1l653ac3ka4apm7s4qrbm4kx7ij7n2zk3b67p9l0nki8vxxi8jv7"; };

        mavenix = import mavenix-src {
          inherit pkgs;
        };

        pkgs = import nixpkgs { 
          inherit system;
        };

        nur-modules = import nur {
          inherit pkgs;
          nurpkgs = pkgs;
        };

        mavenFlags = "-Dassembly.skipAssembly=true -Dskip.unit-tests=true -Dskip.integration-tests=true -Dskip.end-to-end-tests=true -Dmaven.test.skip.exec -DskipTests=true -Dmaven.test.skip=true";

      in rec {
          devShell = pkgs.mkShell {
            name = "shell";
            #TEST = builtins.attrNames mvn2nix.packages."${system}".mvn2nix;
            buildInputs = packages.jitsi-meet.nativeBuildInputs ++ packages.jitsi-videobridge.nativeBuildInputs ++ [ pkgs.starship pkgs.git ];
            shellHook = ''
              eval "$(starship init bash)"
            '';
          };

          packages.jitsi-videobridge = mavenix.buildMaven {
            src = ./.;
            doCheck = false;
            infoFile = ./mavenix.lock;
            MAVEN_OPTS = mavenFlags;
            nativeBuildInputs = with pkgs; [ unzip ];
            postInstall = ''
              mkdir -p $out/{bin,share,etc/jitsi/videobridge}
              unzip jvb/target/jitsi-videobridge-*-archive.zip -d $out/share
              mv $out/share/jitsi-videobridge-* $out/share/jitsi-videobridge
              substituteInPlace $out/share/jitsi-videobridge/jvb.sh \
                --replace "exec java" "exec ${pkgs.jre}/bin/java"
              mv $out/share/jitsi-videobridge/lib/logging.properties $out/etc/jitsi/videobridge/
              cp ${./logging.properties-journal} $out/etc/jitsi/videobridge/logging.properties-journal
              rm $out/share/jitsi-videobridge/jvb.bat
              ln -s $out/share/jitsi-videobridge/jvb.sh $out/bin/jitsi-videobridge
            '';
          };

          # packages.jitsi-videobridge = pkgs.stdenv.mkDerivation {
          #   pname = "jitsi-videobridge";
          #   version = "git";
          #   src = ./jitsi-videobridge;

          #   nativeBuildInputs = [ pkgs.maven pkgs.unzip ];
          #   buildInputs = [ pkgs.jre ];

          #   buildPhase = ''
          #     cp -dpR "${./jitsi-videobridge/.m2}" ./
          #     chmod -R +w .m2
          #     mvn package --offline ${mavenFlags} -Dmaven.repo.local="$(pwd)/.m2"
          #   '';

          #   installPhase = ''
          #     mkdir -p $out/{bin,share,etc/jitsi/videobridge}
          #     unzip jvb/target/jitsi-videobridge-*-archive.zip -d $out/share
          #     mv $out/share/jitsi-videobridge-* $out/share/jitsi-videobridge
          #     substituteInPlace $out/share/jitsi-videobridge/jvb.sh \
          #       --replace "exec java" "exec ${pkgs.jre}/bin/java"
          #     mv $out/share/jitsi-videobridge/lib/logging.properties $out/etc/jitsi/videobridge/
          #     cp ${./logging.properties-journal} $out/etc/jitsi/videobridge/logging.properties-journal
          #     rm $out/share/jitsi-videobridge/jvb.bat
          #     ln -s $out/share/jitsi-videobridge/jvb.sh $out/bin/jitsi-videobridge
          #   '';

          #   # passthru.tests = {
          #   #   inherit (nixosTests) jitsi-meet;
          #   # };

          # };

          # packages.jitsi-videobridge = pkgs.stdenv.mkDerivation rec {
          #   name = "jitsi-videobridge";
          #   version = "2.1+682+g0192d75e8";
          #   pname = name;

          #   src = ./jitsi-videobridge;

          #   nativeBuildInputs = [ pkgs.jdk11 pkgs.maven pkgs.makeWrapper ];
          #   JAVA_HOME = "${pkgs.jdk11}/lib/openjdk";

          #   # org.jitsi:jitsi-media-transform:jar:2.1-SNAPSHOT

          #   buildPhase = ''
          #     echo "Using repository ${mavenRepo}"
          #     # cp -r ${mavenRepo} mavenRepo
          #     # chmod -R 755 mavenRepo
          #     mvn --offline -Dassembly.skipAssembly=true -Dskip.unit-tests=true -Dskip.integration-tests=true -Dskip.end-to-end-tests=true -Dmaven.test.skip.exec -DskipTests=true -Dmaven.test.skip=true -Dmaven.repo.local=${mavenRepo} package install
              
          #     # rtps=(rtp/target/rtp*.jar)
          #     # RTPVERSION=$(basename ''${rtps[1]} .jar | sed -e "s/^rtp-//")
          #     # mkdir -p mavenRepo/org/jitsi/rtp/$RTPVERSION
          #     # cp rtp/target/rtp*.jar mavenRepo/org/jitsi/rtp/$RTPVERSION

          #     # jacs=(jvb-api/jvb-api-common/target/jvb-api-common*.jar)
          #     # JACVERSION=$(basename ''${jacs[0]} .jar | sed -e "s/^jvb-api-common-//")
          #     # mkdir -p mavenRepo/org/jitsi/jvb-api-common/$JACVERSION
          #     # cp jvb-api/jvb-api-common/target/jvb-api-common*.jar mavenRepo/org/jitsi/jvb-api-common/$JACVERSION

          #     # jmts=(jitsi-media-transform/target/jitsi-media-transform*.jar)
          #     # JMTVERSION=$(basename ''${jmts[1]} .jar | sed -e "s/^jitsi-media-transform-//")
          #     # mkdir -p mavenRepo/org/jitsi/jitsi-media-transform/$JMTVERSION
          #     # cp jitsi-media-transform/target/jitsi-media-transform*.jar mavenRepo/org/jitsi/jitsi-media-transform/$JMTVERSION

          #     mvn dependency:copy-dependencies --offline -Dmaven.repo.local=${mavenRepo} -DincludeScope=runtime
          #   '';

          #   installPhase = ''
          #     runHook preInstall
          #     substituteInPlace jvb/resources/jvb.sh \
          #       --replace "exec java" "exec ${pkgs.jdk17_headless}/bin/java"

          #     mkdir -p $out/{bin,share/jitsi-videobridge/lib,etc/jitsi/videobridge}
          #     mv jvb/lib/logging.properties $out/etc/jitsi/videobridge/
          #     cp ${./logging.properties-journal} $out/etc/jitsi/videobridge/logging.properties-journal
          #     mv jvb/resources/jvb.sh $out/share/jitsi-videobridge/
          #     mv jvb/target/jitsi-videobridge-*.jar $out/share/jitsi-videobridge/jitsi-videobridge.jar
          #     mv resources/graceful_shutdown.sh $out/share/jitsi-videobridge/
          #     mv resources/collect-dump-logs.sh $out/share/jitsi-videobridge/
          #     ln -s $out/share/jitsi-videobridge/jvb.sh $out/bin/jitsi-videobridge

          #     cp rtp/target/dependency/*.jar $out/share/jitsi-videobridge/lib
          #     cp jvb/target/dependency/*.jar $out/share/jitsi-videobridge/lib
          #     cp jitsi-media-transform/target/dependency/*.jar $out/share/jitsi-videobridge/lib
          #     cp jvb-api/jvb-api-common/target/dependency/*.jar $out/share/jitsi-videobridge/lib
          #     cp jvb-api/jvb-api-client/target/dependency/*.jar $out/share/jitsi-videobridge/lib
          #     cp jvb/lib/videobridge.rc $out/share/jitsi-videobridge/lib

          #     # work around https://github.com/jitsi/jitsi-videobridge/issues/1547
          #     wrapProgram $out/bin/jitsi-videobridge \
          #       --set VIDEOBRIDGE_GC_TYPE G1GC
          #     runHook postInstall
          #   '';
          # };

          defaultPackage = packages.jitsi-videobridge;

          # apps."${system}" = {
          #   type = "app";
          #   program = "${defaultPackage}/bin/${name}";
          # };

          # defaultApp = apps."${system}";

      }
    );
}