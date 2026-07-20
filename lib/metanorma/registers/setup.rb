# frozen_string_literal: true

module Metanorma
  module Registers
    module Setup
      class << self
        # ============================================================
        # ISO-family registers — fallback to :iso_document
        # ============================================================

        def setup_iso_register
          sd = Metanorma::StandardDocument
          iso = Metanorma::IsoDocument
          reg = Lutaml::Model::Register.new(:iso_document)
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: sd::Sections::ClauseSection,
            to_type: iso::Sections::IsoClauseSection,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::AnnexSection,
            to_type: iso::Sections::IsoAnnexSection,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::Sections,
            to_type: iso::Sections::IsoSections,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::Preface,
            to_type: iso::Sections::IsoPreface,
          )
        end

        def setup_iec_register
          reg = Lutaml::Model::Register.new(:iec_document,
                                            fallback: [:iso_document])
          Lutaml::Model::GlobalRegister.register(reg)
        end

        def setup_oiml_register
          reg = Lutaml::Model::Register.new(:oiml_document,
                                            fallback: [:iso_document])
          Lutaml::Model::GlobalRegister.register(reg)
        end

        def setup_csa_register
          reg = Lutaml::Model::Register.new(:csa_document,
                                            fallback: [:iso_document])
          Lutaml::Model::GlobalRegister.register(reg)
        end

        def setup_bsi_register
          iso = Metanorma::IsoDocument
          reg = Lutaml::Model::Register.new(:bsi_document,
                                            fallback: [:iso_document])
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: iso::Sections::IsoSections,
            to_type: Metanorma::BsiDocument::Sections::BsiSections,
          )
          reg.register_global_type_substitution(
            from_type: iso::Sections::IsoClauseSection,
            to_type: Metanorma::BsiDocument::Sections::BsiClauseSection,
          )
          reg.register_global_type_substitution(
            from_type: iso::Sections::IsoAnnexSection,
            to_type: Metanorma::BsiDocument::Sections::BsiAnnexSection,
          )
        end

        def setup_jis_register
          iso = Metanorma::IsoDocument
          reg = Lutaml::Model::Register.new(:jis_document,
                                            fallback: [:iso_document])
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: iso::Sections::IsoAnnexSection,
            to_type: Metanorma::JisDocument::Sections::JisAnnexSection,
          )
        end

        def setup_gb_register
          reg = Lutaml::Model::Register.new(:gb_document,
                                            fallback: [:iso_document])
          Lutaml::Model::GlobalRegister.register(reg)
        end

        def setup_m3d_register
          reg = Lutaml::Model::Register.new(:m3d_document)
          Lutaml::Model::GlobalRegister.register(reg)
        end

        def setup_plateau_register
          reg = Lutaml::Model::Register.new(:plateau_document,
                                            fallback: [:jis_document])
          Lutaml::Model::GlobalRegister.register(reg)
        end

        # ============================================================
        # Isodoc-family registers — no ISO fallback
        # ============================================================

        def setup_ieee_register
          sd = Metanorma::StandardDocument
          reg = Lutaml::Model::Register.new(:ieee_document)
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: sd::Sections::Sections,
            to_type: Metanorma::IeeeDocument::Sections::IeeeSections,
          )
        end

        def setup_ietf_register
          sd = Metanorma::StandardDocument
          reg = Lutaml::Model::Register.new(:ietf_document)
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: sd::Sections::Sections,
            to_type: Metanorma::IetfDocument::Sections::IetfSections,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::ContentSection,
            to_type: Metanorma::IetfDocument::Sections::IetfContentSection,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::ClauseSection,
            to_type: Metanorma::IetfDocument::Sections::IetfClauseSection,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::AnnexSection,
            to_type: Metanorma::IetfDocument::Sections::IetfAnnexSection,
          )
        end

        def setup_nist_register
          sd = Metanorma::StandardDocument
          reg = Lutaml::Model::Register.new(:nist_document)
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: sd::Sections::Preface,
            to_type: Metanorma::NistDocument::Sections::NistPreface,
          )
        end

        def setup_un_register
          sd = Metanorma::StandardDocument
          reg = Lutaml::Model::Register.new(:un_document)
          Lutaml::Model::GlobalRegister.register(reg)

          reg.register_global_type_substitution(
            from_type: sd::Sections::Sections,
            to_type: Metanorma::UnDocument::Sections::UnSections,
          )
          reg.register_global_type_substitution(
            from_type: sd::Sections::Preface,
            to_type: Metanorma::UnDocument::Sections::UnPreface,
          )
        end
      end
    end
  end
end
