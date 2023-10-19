{ stdenv, fetchurl }:
  let
    mkJenkinsPlugin = { name, src }:
      stdenv.mkDerivation {
        inherit name src;
        phases = "installPhase";
        installPhase = "cp \$src \$out";
        };
  in {
    antisamy-markup-formatter = mkJenkinsPlugin {
      name = "antisamy-markup-formatter";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/antisamy-markup-formatter/162.v0e6ec0fcfcf6/antisamy-markup-formatter.hpi";
        sha256 = "3d4144a78b14ccc4a8f370ccea82c93bd56fadd900b2db4ebf7f77ce2979efd6";
        };
      };
    apache-httpcomponents-client-4-api = mkJenkinsPlugin {
      name = "apache-httpcomponents-client-4-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/apache-httpcomponents-client-4-api/4.5.14-208.v438351942757/apache-httpcomponents-client-4-api.hpi";
        sha256 = "9ed0ccda20a0ea11e2ba5be299f03b30692dd5a2f9fdc7853714507fda8acd0f";
        };
      };
    bootstrap5-api = mkJenkinsPlugin {
      name = "bootstrap5-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/bootstrap5-api/5.3.2-2/bootstrap5-api.hpi";
        sha256 = "cb3de370abbc6f0e383be94bc42e70f19b5b95c41ef877152e4ca76e1e69451d";
        };
      };
    bouncycastle-api = mkJenkinsPlugin {
      name = "bouncycastle-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/bouncycastle-api/2.29/bouncycastle-api.hpi";
        sha256 = "b4579237ea34c5d45d02c8cb16ca35794163ca114d87dfb75e84949798a18ee6";
        };
      };
    branch-api = mkJenkinsPlugin {
      name = "branch-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/branch-api/2.1128.v717130d4f816/branch-api.hpi";
        sha256 = "59cfd93c68cbb08069ab723d20d080c1b5dbfe501baff448f953f40f46d0edd3";
        };
      };
    caffeine-api = mkJenkinsPlugin {
      name = "caffeine-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/caffeine-api/3.1.8-133.v17b_1ff2e0599/caffeine-api.hpi";
        sha256 = "a6c614655bc507345bf16b5c4615bb09b1a20f934c9bf0b15c02ccea4a5c0400";
        };
      };
    checks-api = mkJenkinsPlugin {
      name = "checks-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/checks-api/2.0.2/checks-api.hpi";
        sha256 = "445a5fbd2cea215aee02023a3ae7a1066a1120f29d7280c5777abf9aacc1a631";
        };
      };
    cloudbees-folder = mkJenkinsPlugin {
      name = "cloudbees-folder";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/cloudbees-folder/6.858.v898218f3609d/cloudbees-folder.hpi";
        sha256 = "b5a6b0a896ed662f3b705b1f41372d908780d116e81ccfb4a0f43d36d972d9aa";
        };
      };
    command-launcher = mkJenkinsPlugin {
      name = "command-launcher";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/command-launcher/107.v773860566e2e/command-launcher.hpi";
        sha256 = "72e0ae8c9a31ac7f5a3906f7cacd34de26bdca3767bfef87027723850a68ca19";
        };
      };
    commons-lang3-api = mkJenkinsPlugin {
      name = "commons-lang3-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/commons-lang3-api/3.13.0-62.v7d18e55f51e2/commons-lang3-api.hpi";
        sha256 = "e27bbec4d37f26e7da0d0732b241ad0eb2b60826c3f7521808b1442727f54858";
        };
      };
    commons-text-api = mkJenkinsPlugin {
      name = "commons-text-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/commons-text-api/1.10.0-78.v3e7b_ea_d5a_fe1/commons-text-api.hpi";
        sha256 = "2b64e03f6aad138b31aa3dcf2f2f82b56f21dcac23315a1e6399e5c55c5effa8";
        };
      };
    conditional-buildstep = mkJenkinsPlugin {
      name = "conditional-buildstep";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/conditional-buildstep/1.4.3/conditional-buildstep.hpi";
        sha256 = "d2ce40b86abc42372085ace0a6bb3785d14ae27f0824709dfc2a2b3891a9e8a8";
        };
      };
    config-file-provider = mkJenkinsPlugin {
      name = "config-file-provider";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/config-file-provider/959.vcff671a_4518b_/config-file-provider.hpi";
        sha256 = "bd39b7128af48a47551c9a0f42d4c5ae656abe5aa3ad77e43b3c8ed27bb61838";
        };
      };
    configuration-as-code = mkJenkinsPlugin {
      name = "configuration-as-code";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/configuration-as-code/1714.v09593e830cfa/configuration-as-code.hpi";
        sha256 = "da557379507cb285ad671187e2c4f24bc3816ebb13e4d01afef02a89bd888887";
        };
      };
    credentials = mkJenkinsPlugin {
      name = "credentials";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/credentials/1293.vff276f713473/credentials.hpi";
        sha256 = "de8fac186ca920dc0545544fad30f8e54e7dbf3e68218d965c83b1be559c9bd5";
        };
      };
    credentials-binding = mkJenkinsPlugin {
      name = "credentials-binding";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/credentials-binding/636.v55f1275c7b_27/credentials-binding.hpi";
        sha256 = "dfb606a8a625a04c5a38282750d8d461b66ca57daad4a23fa22d0bedd518f6de";
        };
      };
    display-url-api = mkJenkinsPlugin {
      name = "display-url-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/display-url-api/2.200.vb_9327d658781/display-url-api.hpi";
        sha256 = "2c43127027b16518293b94fa3f1792b7bd3db7234380c6a5249275d480fcbd04";
        };
      };
    durable-task = mkJenkinsPlugin {
      name = "durable-task";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/durable-task/523.va_a_22cf15d5e0/durable-task.hpi";
        sha256 = "1e66bd3e83829c679d0a3535495a3a4611e40a79bd54c7c567b559f4ddba7a4a";
        };
      };
    echarts-api = mkJenkinsPlugin {
      name = "echarts-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/echarts-api/5.4.0-7/echarts-api.hpi";
        sha256 = "a4b92526fec4676b77ad456b3835fb575afc748e99bb83623ff6df6753bb837c";
        };
      };
    font-awesome-api = mkJenkinsPlugin {
      name = "font-awesome-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/font-awesome-api/6.4.2-1/font-awesome-api.hpi";
        sha256 = "61438b6eacb38e60159b63fd35eecc4f2ff28f41db614a83f97e3a6caea7438a";
        };
      };
    git = mkJenkinsPlugin {
      name = "git";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/git/5.2.0/git.hpi";
        sha256 = "86895fb0350a0fc7904fdad661d5c36fa7d2f7783e151fe44b83f48b4e75dc7e";
        };
      };
    git-client = mkJenkinsPlugin {
      name = "git-client";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/git-client/4.5.0/git-client.hpi";
        sha256 = "0e95b91fff1c4abe9f480f4fecb4fbbb3290bbf6ddaca787e099c8c3b0097d7c";
        };
      };
    github = mkJenkinsPlugin {
      name = "github";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/github/1.37.3/github.hpi";
        sha256 = "5bbb837a65f062d6ebe11032605e869d0dc6e37bb38dba73e54b60ede0e97cf7";
        };
      };
    github-api = mkJenkinsPlugin {
      name = "github-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/github-api/1.316-451.v15738eef3414/github-api.hpi";
        sha256 = "3150c0efb920e4bd7c4b69de507d23ec4954abf23cdc951e4172ed75f0e3ba5b";
        };
      };
    github-branch-source = mkJenkinsPlugin {
      name = "github-branch-source";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/github-branch-source/1741.va_3028eb_9fd21/github-branch-source.hpi";
        sha256 = "1bc04965516674b3fc550532cf854f079247aff9465402f7dce44eca9baa9634";
        };
      };
    instance-identity = mkJenkinsPlugin {
      name = "instance-identity";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/instance-identity/173.va_37c494ec4e5/instance-identity.hpi";
        sha256 = "0e240647854068c21fec3f3dbe449bf1a29356a1dea87646cb1ac813bec37c79";
        };
      };
    ionicons-api = mkJenkinsPlugin {
      name = "ionicons-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/ionicons-api/56.v1b_1c8c49374e/ionicons-api.hpi";
        sha256 = "4a6176a2169481fec295c900a6291b3b809b8dd17805868abbdc8a7a322169ca";
        };
      };
    jackson2-api = mkJenkinsPlugin {
      name = "jackson2-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jackson2-api/2.15.3-366.vfe8d1fa_f8c87/jackson2-api.hpi";
        sha256 = "c5343e06f567ba1a72164a66c23e43f7635159bd6fede97d57fa7dbaf6d405b0";
        };
      };
    jakarta-activation-api = mkJenkinsPlugin {
      name = "jakarta-activation-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jakarta-activation-api/2.0.1-3/jakarta-activation-api.hpi";
        sha256 = "fa99c0288dcd24e7bbc857974d07a622d19d48ba71a39564b6c1fa9a14773ed1";
        };
      };
    jakarta-mail-api = mkJenkinsPlugin {
      name = "jakarta-mail-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jakarta-mail-api/2.0.1-3/jakarta-mail-api.hpi";
        sha256 = "af8d0ed38eed3231a078291c4c5f1f0c342970a860a88cdd11ff3ebb606bd3b7";
        };
      };
    javadoc = mkJenkinsPlugin {
      name = "javadoc";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/javadoc/243.vb_b_503b_b_45537/javadoc.hpi";
        sha256 = "0dfffce64e478edcdbbfde2df5913be2ff46e5e033daff8bc9bb616ca7528999";
        };
      };
    javax-activation-api = mkJenkinsPlugin {
      name = "javax-activation-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/javax-activation-api/1.2.0-6/javax-activation-api.hpi";
        sha256 = "8af800837a3bddca75d7f962fbcf535d1c3c214f323fa57c141cecdde61516a9";
        };
      };
    jaxb = mkJenkinsPlugin {
      name = "jaxb";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jaxb/2.3.8-1/jaxb.hpi";
        sha256 = "607213a0b4d959f9982ef53e908c8cfc37f2334e38bb49487f7f8eed6b6c4956";
        };
      };
    jjwt-api = mkJenkinsPlugin {
      name = "jjwt-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jjwt-api/0.11.5-77.v646c772fddb_0/jjwt-api.hpi";
        sha256 = "cc10fc60c47fe60a585224dad45dde166dd0268cf6efc9967fbf870e3601ceb2";
        };
      };
    job-dsl = mkJenkinsPlugin {
      name = "job-dsl";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/job-dsl/1.86/job-dsl.hpi";
        sha256 = "effa0953aa03b0349b64d79653db7326137834cff1f2312054bbf941f82972ac";
        };
      };
    jquery3-api = mkJenkinsPlugin {
      name = "jquery3-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jquery3-api/3.7.1-1/jquery3-api.hpi";
        sha256 = "f9c62c1c7c3886408e8b7ae9b1dca62797793ee27e349dd1106fa28fb43f0040";
        };
      };
    jsch = mkJenkinsPlugin {
      name = "jsch";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/jsch/0.2.8-65.v052c39de79b_2/jsch.hpi";
        sha256 = "1267c1d0f48ee3c00fb325a5c53ef5ec73eae4daeab27c5bf55f235069055abe";
        };
      };
    junit = mkJenkinsPlugin {
      name = "junit";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/junit/1240.vf9529b_881428/junit.hpi";
        sha256 = "94a7f88d219922e2ae9de0a016668f3e689d71cb39ef01c4fe6dac03e9909e0e";
        };
      };
    mailer = mkJenkinsPlugin {
      name = "mailer";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mailer/463.vedf8358e006b_/mailer.hpi";
        sha256 = "e732d5e291b047a423ced942140c4a0cefa08fe4a40dba69ad5c5af53bba593e";
        };
      };
    mapdb-api = mkJenkinsPlugin {
      name = "mapdb-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mapdb-api/1.0.9-28.vf251ce40855d/mapdb-api.hpi";
        sha256 = "b924749b6445270cd2ed881f81925fedd71f67a2993473b9172e1e7a9a4023be";
        };
      };
    matrix-project = mkJenkinsPlugin {
      name = "matrix-project";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/matrix-project/818.v7eb_e657db_924/matrix-project.hpi";
        sha256 = "7490ae44ffa212b713cda2b9d15fe576d7875d66104e66a3a9c8c19b479e4632";
        };
      };
    maven-plugin = mkJenkinsPlugin {
      name = "maven-plugin";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/maven-plugin/3.23/maven-plugin.hpi";
        sha256 = "f412f9701aafa46d8e68dccb046b41745f2116ad91b76b0f35a24f21830097eb";
        };
      };
    metrics = mkJenkinsPlugin {
      name = "metrics";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/metrics/4.2.18-442.v02e107157925/metrics.hpi";
        sha256 = "8c552715237b7bb2b9b6a1b9806d691e4043d5416f732cde2c293b01d361d90f";
        };
      };
    mina-sshd-api-common = mkJenkinsPlugin {
      name = "mina-sshd-api-common";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mina-sshd-api-common/2.10.0-69.v28e3e36d18eb_/mina-sshd-api-common.hpi";
        sha256 = "50090b0f09294b051c2415311a5fe8a1c602f2e515b2609936eead5e5a164ceb";
        };
      };
    mina-sshd-api-core = mkJenkinsPlugin {
      name = "mina-sshd-api-core";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/mina-sshd-api-core/2.10.0-69.v28e3e36d18eb_/mina-sshd-api-core.hpi";
        sha256 = "2414182b5cc988a6d28fee6a35286e95bf7b841749c3b27c979021f88277890e";
        };
      };
    node-iterator-api = mkJenkinsPlugin {
      name = "node-iterator-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/node-iterator-api/49.v58a_8b_35f8363/node-iterator-api.hpi";
        sha256 = "106b4ba84478412d2f7bb30fa7e4aad13c5235b235cfbbf62f072904342969ea";
        };
      };
    okhttp-api = mkJenkinsPlugin {
      name = "okhttp-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/okhttp-api/4.11.0-157.v6852a_a_fa_ec11/okhttp-api.hpi";
        sha256 = "1ac8e08914923edcf5e1826b948d6c89f20d9247949105be0869c3e397b79eb6";
        };
      };
    parameterized-trigger = mkJenkinsPlugin {
      name = "parameterized-trigger";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.46/parameterized-trigger.hpi";
        sha256 = "b7807a1dd4ffc44ec446835f8d42b33b5d0456b44093a602783f553aa4003100";
        };
      };
    pipeline-build-step = mkJenkinsPlugin {
      name = "pipeline-build-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-build-step/505.v5f0844d8d126/pipeline-build-step.hpi";
        sha256 = "1163570e8a9b7672e8c2ec5bc779f943baea61d71740896529dfd2e428b94673";
        };
      };
    pipeline-graph-analysis = mkJenkinsPlugin {
      name = "pipeline-graph-analysis";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-graph-analysis/202.va_d268e64deb_3/pipeline-graph-analysis.hpi";
        sha256 = "3ea34acec187c036d5e688192dcd75e70fc1c6b1018969c1c04ae7f1e6bb3410";
        };
      };
    pipeline-graph-view = mkJenkinsPlugin {
      name = "pipeline-graph-view";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-graph-view/202.v6da_a_9e590325/pipeline-graph-view.hpi";
        sha256 = "32cf5baf0d8cae96fc8df890ff721ebfa0fd69982689e331d543ea3242a098da";
        };
      };
    pipeline-groovy-lib = mkJenkinsPlugin {
      name = "pipeline-groovy-lib";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-groovy-lib/689.veec561a_dee13/pipeline-groovy-lib.hpi";
        sha256 = "75ce8286ac7584e7cf8ad4a62f079380dd7f7305e1bbe13acdac73d174df4494";
        };
      };
    pipeline-input-step = mkJenkinsPlugin {
      name = "pipeline-input-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-input-step/477.v339683a_8d55e/pipeline-input-step.hpi";
        sha256 = "b25598cf76c788563ba667c2ab82348842b95db133d378395536f777ee2be00f";
        };
      };
    pipeline-milestone-step = mkJenkinsPlugin {
      name = "pipeline-milestone-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-milestone-step/111.v449306f708b_7/pipeline-milestone-step.hpi";
        sha256 = "48bea7547ad989b0c1abb550c3e2ff27bb48d7ff7685e84c0f39d5148bf6fd6b";
        };
      };
    pipeline-model-api = mkJenkinsPlugin {
      name = "pipeline-model-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-api/2.2144.v077a_d1928a_40/pipeline-model-api.hpi";
        sha256 = "579e49d96527e09c25e42ff3dc1f320adef7ee0a8e2761de5e10cc1c0f02fcff";
        };
      };
    pipeline-model-definition = mkJenkinsPlugin {
      name = "pipeline-model-definition";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-definition/2.2144.v077a_d1928a_40/pipeline-model-definition.hpi";
        sha256 = "407126434abeaf8db0224c2896b246b36ae165428ba7b53f932dc52b206b73bd";
        };
      };
    pipeline-model-extensions = mkJenkinsPlugin {
      name = "pipeline-model-extensions";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-model-extensions/2.2144.v077a_d1928a_40/pipeline-model-extensions.hpi";
        sha256 = "fccea0e049b8c0a133ce750df97123fe5ff99d2141beec634e0aa98e6b582fc9";
        };
      };
    pipeline-stage-step = mkJenkinsPlugin {
      name = "pipeline-stage-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-stage-step/305.ve96d0205c1c6/pipeline-stage-step.hpi";
        sha256 = "8d5112dd70d9912f33bdb64858bbfa718372ab79447fa91f1e07fdb41c05bb7e";
        };
      };
    pipeline-stage-tags-metadata = mkJenkinsPlugin {
      name = "pipeline-stage-tags-metadata";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-stage-tags-metadata/2.2144.v077a_d1928a_40/pipeline-stage-tags-metadata.hpi";
        sha256 = "f67de16861c6fa53b3ef41bd8eaf2f73ca2221daca9dadd8c3164e17f47d94f2";
        };
      };
    pipeline-utility-steps = mkJenkinsPlugin {
      name = "pipeline-utility-steps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/pipeline-utility-steps/2.16.0/pipeline-utility-steps.hpi";
        sha256 = "dfe39235dffbe5bfd10c39fb652e313dd9c0b3b7e44dbf275326eb64da94c754";
        };
      };
    plain-credentials = mkJenkinsPlugin {
      name = "plain-credentials";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/plain-credentials/143.v1b_df8b_d3b_e48/plain-credentials.hpi";
        sha256 = "23a74199dcb19659e19c9d92e4797b40bc9feb48400ce56ae43fa4d9520df901";
        };
      };
    plugin-util-api = mkJenkinsPlugin {
      name = "plugin-util-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/plugin-util-api/3.6.0/plugin-util-api.hpi";
        sha256 = "d14d9d82d1fe3af55575900f913daf5976b768ab9d766b567e5a9e6c070bd5ec";
        };
      };
    prism-api = mkJenkinsPlugin {
      name = "prism-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/prism-api/1.29.0-8/prism-api.hpi";
        sha256 = "71b6df5cbbe75174127b1eb732cba5d78a4936a54e248280f8d1f3e31445fc89";
        };
      };
    project-inheritance = mkJenkinsPlugin {
      name = "project-inheritance";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/project-inheritance/21.04.03/project-inheritance.hpi";
        sha256 = "c7e714d2a096ceb719f9a91eb61d12c6da1619f139254ce91db1ead58520ecf7";
        };
      };
    promoted-builds = mkJenkinsPlugin {
      name = "promoted-builds";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/promoted-builds/936.va_571a_a_b_f8da_5/promoted-builds.hpi";
        sha256 = "dc769a1ba9fc95963853151662decb9d42f359eac68333331a52e1d02e8906cc";
        };
      };
    rebuild = mkJenkinsPlugin {
      name = "rebuild";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/rebuild/320.v5a_0933a_e7d61/rebuild.hpi";
        sha256 = "9b09a256f8a81edc984b688de07c795c22122585c5ce0148e703d20cbce4dfd8";
        };
      };
    role-strategy = mkJenkinsPlugin {
      name = "role-strategy";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/role-strategy/689.v731678c3e0eb_/role-strategy.hpi";
        sha256 = "b98e9735bc57dd0a39ca484db03e5d1bcc06d7634fa4053ff2aaf2b28eb91704";
        };
      };
    run-condition = mkJenkinsPlugin {
      name = "run-condition";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/run-condition/1.7/run-condition.hpi";
        sha256 = "d8601f47c021f8c6b8275735f5c023fec57b65189028e21abac91d42add0be42";
        };
      };
    scm-api = mkJenkinsPlugin {
      name = "scm-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/scm-api/676.v886669a_199a_a_/scm-api.hpi";
        sha256 = "c8cc7b2120d25977cefc2fa6cc3830be034971e63f5009aee516d984025a837a";
        };
      };
    script-security = mkJenkinsPlugin {
      name = "script-security";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/script-security/1275.v23895f409fb_d/script-security.hpi";
        sha256 = "31bb87d3db38951197fe0ec20062e07247ed4101a266f418678a5006e35eff0a";
        };
      };
    snakeyaml-api = mkJenkinsPlugin {
      name = "snakeyaml-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/snakeyaml-api/2.2-111.vc6598e30cc65/snakeyaml-api.hpi";
        sha256 = "11013a4ab9f8c93420ba6ec85faab53759ea8afd53ba2db3f97c0ed4f0ebe82b";
        };
      };
    ssh-credentials = mkJenkinsPlugin {
      name = "ssh-credentials";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/ssh-credentials/308.ve4497b_ccd8f4/ssh-credentials.hpi";
        sha256 = "23984ee5cfede3526a13714c82426db6d8e63c5635f9c6aac89a48c246000be2";
        };
      };
    ssh-slaves = mkJenkinsPlugin {
      name = "ssh-slaves";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/ssh-slaves/2.916.vd17b_43357ce4/ssh-slaves.hpi";
        sha256 = "27e283eaab9dd5fa250c2ef579a31018cbdfe80db044d2afe2cbdef808f39842";
        };
      };
    structs = mkJenkinsPlugin {
      name = "structs";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/structs/325.vcb_307d2a_2782/structs.hpi";
        sha256 = "2300dd3ce12775760e7898c8626567732366e1da652a4121f98aa3effdd1e3e1";
        };
      };
    subversion = mkJenkinsPlugin {
      name = "subversion";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/subversion/2.17.3/subversion.hpi";
        sha256 = "e972712afe0225b4706e38b2352ae11c026b170cc023e68e40e87dfbd9c267a5";
        };
      };
    support-core = mkJenkinsPlugin {
      name = "support-core";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/support-core/1356.vd0f980edfa_46/support-core.hpi";
        sha256 = "d0c7d10e365460fdb29116b1ed34755ecd7dbb968ad783870b083b2396b05572";
        };
      };
    token-macro = mkJenkinsPlugin {
      name = "token-macro";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/token-macro/384.vf35b_f26814ec/token-macro.hpi";
        sha256 = "eb099a1198aec1bdc1b04be7504611367923a467b03b801ea21fb6705bc9991d";
        };
      };
    trilead-api = mkJenkinsPlugin {
      name = "trilead-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/trilead-api/2.84.v72119de229b_7/trilead-api.hpi";
        sha256 = "72ee883ee83a94a0a84e9821123ae3f1eb09e7650896c5e0a78be8d0df50bde8";
        };
      };
    variant = mkJenkinsPlugin {
      name = "variant";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/variant/60.v7290fc0eb_b_cd/variant.hpi";
        sha256 = "acbf1aebb9607efe0518b33c9dde9bd50c03d6a1a0fa62255865f3cf941fa458";
        };
      };
    vsphere-cloud = mkJenkinsPlugin {
      name = "vsphere-cloud";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/vsphere-cloud/2.27/vsphere-cloud.hpi";
        sha256 = "b584e8c515cdf41fa47740087677e11af80c402ef6c4fb5f153b9d8e05ccbdea";
        };
      };
    workflow-aggregator = mkJenkinsPlugin {
      name = "workflow-aggregator";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-aggregator/596.v8c21c963d92d/workflow-aggregator.hpi";
        sha256 = "45933e33058d48c6f3e70a37f31ecb65e48939ce91d46bc98b60f5595316c1d1";
        };
      };
    workflow-api = mkJenkinsPlugin {
      name = "workflow-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-api/1283.v99c10937efcb_/workflow-api.hpi";
        sha256 = "06be7f5181d1c4445feb5866257f437910944119c50851f2e368fd89527e4358";
        };
      };
    workflow-basic-steps = mkJenkinsPlugin {
      name = "workflow-basic-steps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-basic-steps/1042.ve7b_140c4a_e0c/workflow-basic-steps.hpi";
        sha256 = "ab0f9d989a1885ae6f5148c9acc6ffcf1667bf427c6d392eaf8cf1cd1b670345";
        };
      };
    workflow-cps = mkJenkinsPlugin {
      name = "workflow-cps";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-cps/3802.vd42b_fcf00b_a_c/workflow-cps.hpi";
        sha256 = "f3ab8bf26c52057da6bcc68e6a7ec507ee359ab291c30830c90008084deb2a38";
        };
      };
    workflow-durable-task-step = mkJenkinsPlugin {
      name = "workflow-durable-task-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-durable-task-step/1289.v4d3e7b_01546b_/workflow-durable-task-step.hpi";
        sha256 = "6565675b1e8eba8121dd7ca90bb18e74e76f2dab1b0e40d851b60dc9e9b05d42";
        };
      };
    workflow-job = mkJenkinsPlugin {
      name = "workflow-job";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-job/1348.v32a_a_f150910e/workflow-job.hpi";
        sha256 = "5f519cb4b9c164e558037392c01419dbef46db9889195558498b96dbdda37a09";
        };
      };
    workflow-multibranch = mkJenkinsPlugin {
      name = "workflow-multibranch";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-multibranch/756.v891d88f2cd46/workflow-multibranch.hpi";
        sha256 = "f3f690324e297c8f263ac21b0a3daa5d60877a2214f6eca2d28d4946d97964b8";
        };
      };
    workflow-scm-step = mkJenkinsPlugin {
      name = "workflow-scm-step";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-scm-step/415.v434365564324/workflow-scm-step.hpi";
        sha256 = "500720bf8a634363c79ae16d56b88493c211fdb33e163b5d17fb52a85f53508e";
        };
      };
    workflow-step-api = mkJenkinsPlugin {
      name = "workflow-step-api";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-step-api/639.v6eca_cd8c04a_a_/workflow-step-api.hpi";
        sha256 = "e297994ef4892b292fed850431cafe5a687fe64fbb9ddf9b7938d2b74db81763";
        };
      };
    workflow-support = mkJenkinsPlugin {
      name = "workflow-support";
      src = fetchurl {
        url = "https://updates.jenkins-ci.org/download/plugins/workflow-support/865.v43e78cc44e0d/workflow-support.hpi";
        sha256 = "4a12fcb84863252e4d26198ce3b53bcdc66f25f1b54865e66be02d397ba001a0";
        };
      };
    }