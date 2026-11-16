# B1 HTML capability gap inventory

Baseline: metanorma-document fe6e0ec11f1ad6f61aef5dd6a55975f288b25faa. Reference: isodoc 033d46c6148594a3649d100a886352c8a0215ab6.

## Measurement and scope

Source scan found 19 non-archived repositories with a lib/**/html_convert.rb: bipm, bsi, cc, csa, gb, generic, iec, ieee, iho, iso, itu, jis, m3aawg, mpfa, nist, ogc, plateau, ribose, un. There are 44 titlepage/intro template files in these repositories. These are source consumers, not a count of production builds. Inheritance of HtmlConvert establishes use of its shared postprocessors; fixture matches below establish sample usage only. No headless converter name occurs in these flavor lib sources; headless is a shared isodoc API. IETF uses its separate RFC/XML output path and is not an isodoc HTML subclass consumer. Standoc supplies base models, not a bespoke cover. Taste-only repositories (e.g. pdfa/icc) must be followed into metanorma-taste rather than treated as missing implementations.

Reproduce: run the saved evidence/b1-inventory.py source scan in the local work area. Raw measurements, source locations, clone logs and GitHub metadata snapshots are retained under ~/work/metanorma/evidence/b1-*.json and b1-source-extracts.txt. Revisions are listed below. The script scans lib Ruby, titlepage/intro asset filenames, and form-bearing spec fixtures; it does not execute every flavor. Repository archive status comes from the GitHub metadata snapshot; page 5 returned Server Error, so that page supplies no archive evidence.

## Feature mapping before implementation

| isodoc feature | Consumers / evidence | metanorma-document baseline |
|---|---|---|
| HeadlessHtmlConvert#strip_head | Shared API; no direct name matches in measured flavor lib sources | MISSING: generate_body is a content fragment, without the legacy outer div or body chrome |
| postprocess_footnotes: backlinks and reference layout | All HTML subclasses inherit html_cleanup → html_footnote; ISO overrides reference formatting | PARTIAL: collector, popup, endnotes and table tfoot exist; duplicate fnref IDs and no adjacent-marker delimiter |
| form: form/input/select/option/label/textarea | Shared Form module; form fixtures in bipm, bsi, iec, ieee, iso; inherited availability is broader than fixtures | MISSING: form emits div; input drops attributes and always disables; select/label/option/textarea dispatch absent |
| postprocess_cover: html_cover/html_intro | Explicit paths and inherited generic covers listed below | PARTIAL: theme template resolution and _cover exist; no independent intro/titlepage slots or front-matter data contract |
| authority_cleanup / boilerplate destinations | All consumers inherit; bsi, iec, itu, nist, ogc customize cleanup | PARTIAL: typed boilerplate rendering exists; destination placement requires structured template assigns, not DOM moves |
| coverpage_note_cleanup | Shared; nist explicitly calls it | MISSING: coverpage annotations must be routed from typed models to a cover slot |
| htmlstyle / inject_script / html_main / html_toc | Shared HTML consumers | Replacement: Theme assets/CSS, AssetPipeline, document Liquid layout and collected TOC; no post-render DOM rewrite |
| heading_anchors / sourcecode_cleanup / html_list_clean / mathml / resize_images / move_images | Shared cleanup chain | Existing rendering/components and asset pipeline are the architectural replacement; exact per-flavor output parity requires the epic regression harness. B1 specs do not prove that gate |

## Flavor source consumers

| Flavor | Legacy cover/intro assets | HTML source evidence | Revision |
|---|---|---|---|
| bipm | lib/isodoc/bipm/html/html_bipm_intro.html<br>lib/isodoc/bipm/html/html_bipm_titlepage.html | lib/isodoc/bipm/html_convert.rb:8: class HtmlConvert < IsoDoc::Generic::HtmlConvert | 38d804b7ab7755acda4cb7b22f2c34057df9d4af |
| bsi | lib/isodoc/bsi/html/html_bsi_intro.html<br>lib/isodoc/bsi/html/html_bsi_titlepage.html | lib/isodoc/bsi/html_convert.rb:8: class HtmlConvert < IsoDoc::Iso::HtmlConvert<br>lib/isodoc/bsi/html_convert.rb:29: htmlcoverpage: html_doc_path("html_bsi_titlepage.html"),<br>lib/isodoc/bsi/html_convert.rb:30: htmlintropage: html_doc_path("html_bsi_intro.html"),<br>lib/isodoc/bsi/html_convert.rb:41: def authority_cleanup(docxml) | c267be75f959a253bc82d4b02c13db1bff4a9673 |
| cc | lib/isodoc/cc/html/html_cc_intro.html<br>lib/isodoc/cc/html/html_cc_titlepage.html | lib/isodoc/cc/html_convert.rb:10: class HtmlConvert < IsoDoc::Generic::HtmlConvert | 23eb5bfe21b9f5c5fb1cc8b58d364d5432244dae |
| csa | lib/isodoc/csa/html/html_csa_intro.html<br>lib/isodoc/csa/html/html_csa_titlepage.html | lib/isodoc/csa/html_convert.rb:12: class HtmlConvert < IsoDoc::Generic::HtmlConvert | 0c9a34d37cb9047a6c446ff4b94f9c025f0da075 |
| gb | lib/gbdoc/html/html_gb_intro.html<br>lib/gbdoc/html/html_gb_titlepage.html<br>lib/isodoc/gb/html/html_compliant_gb_titlepage.html<br>lib/isodoc/gb/html/html_gb_intro.html<br>lib/isodoc/gb/html/html_gb_titlepage.html | lib/isodoc/gb/html_convert.rb:9: class HtmlConvert < IsoDoc::HtmlConvert<br>lib/isodoc/gb/html_convert.rb:44: htmlcoverpage: html_doc_path("html_compliant_gb_titlepage.html"),<br>lib/isodoc/gb/html_convert.rb:45: htmlintropage: html_doc_path("html_gb_intro.html"), | d67597aa36da3ffc7a520e3fd351f15f41911d08 |
| generic | lib/isodoc/generic/html/html_generic_intro.html<br>lib/isodoc/generic/html/html_generic_titlepage.html<br>spec/assets/htmlintropage.html | lib/isodoc/generic/html_convert.rb:10: class HtmlConvert < IsoDoc::HtmlConvert<br>lib/isodoc/generic/html_convert.rb:52: htmlcoverpage: baselocation(configuration.htmlcoverpage) ||<br>lib/isodoc/generic/html_convert.rb:54: htmlintropage: baselocation(configuration.htmlintropage) || | cb41786ff4feb4b730a1154a6ff82f2171dbe064 |
| iec | lib/isodoc/iec/html/html_iec_intro.html<br>lib/isodoc/iec/html/html_iec_titlepage.html | lib/isodoc/iec/html_convert.rb:8: class HtmlConvert < IsoDoc::Iso::HtmlConvert<br>lib/isodoc/iec/html_convert.rb:28: htmlcoverpage: html_doc_path("html_iec_titlepage.html"),<br>lib/isodoc/iec/html_convert.rb:29: htmlintropage: html_doc_path("html_iec_intro.html"),<br>lib/isodoc/iec/html_convert.rb:40: def authority_cleanup(docxml) | 74e017c884f2b6b1811b4dbf8dc055be82176eb2 |
| ieee | lib/isodoc/ieee/html/html_ieee_intro.html<br>lib/isodoc/ieee/html/html_ieee_titlepage.html | lib/isodoc/ieee/html_convert.rb:6: class HtmlConvert < IsoDoc::HtmlConvert<br>lib/isodoc/ieee/html_convert.rb:34: htmlcoverpage: html_doc_path("html_ieee_titlepage.html"),<br>lib/isodoc/ieee/html_convert.rb:35: htmlintropage: html_doc_path("html_ieee_intro.html"), | b92dd9d16f723f8b9b4abb68ee67b9edc6ac3037 |
| iho | lib/isodoc/iho/html/html_iho_intro.html<br>lib/isodoc/iho/html/html_iho_titlepage.html | lib/isodoc/iho/html_convert.rb:7: class HtmlConvert < IsoDoc::Generic::HtmlConvert | a1657ab9d50057419229566f5740e000e8e8852b |
| iso | lib/isodoc/iso/html/html_iso_intro.html<br>lib/isodoc/iso/html/html_iso_titlepage.html<br>spec/assets/htmlintro.html | lib/isodoc/iso/html_convert.rb:7: class HtmlConvert < IsoDoc::HtmlConvert<br>lib/isodoc/iso/html_convert.rb:51: htmlcoverpage: html_doc_path("html_iso_titlepage.html"),<br>lib/isodoc/iso/html_convert.rb:52: htmlintropage: html_doc_path("html_iso_intro.html"),<br>lib/isodoc/iso/html_convert.rb:56: def footnote_reference_format(link) | c11202c7656b8367d3047505bfb5f8157151a228 |
| itu | lib/isodoc/itu/html/html_itu_intro.html<br>lib/isodoc/itu/html/html_itu_titlepage.html | lib/isodoc/itu/html_convert.rb:10: class HtmlConvert < IsoDoc::HtmlConvert<br>lib/isodoc/itu/html_convert.rb:39: htmlcoverpage: html_doc_path("html_itu_titlepage.html"),<br>lib/isodoc/itu/html_convert.rb:40: htmlintropage: html_doc_path("html_itu_intro.html"),<br>lib/isodoc/itu/html_convert.rb:60: def authority_cleanup(docxml) | 1c5bf3515d813be7de60e7d8178c7a3648552f63 |
| jis | lib/isodoc/jis/html/html_jis_intro.html<br>lib/isodoc/jis/html/html_jis_titlepage.html | lib/isodoc/jis/html_convert.rb:3: class HtmlConvert < IsoDoc::Iso::HtmlConvert<br>lib/isodoc/jis/html_convert.rb:28: htmlcoverpage: html_doc_path("html_jis_titlepage.html"),<br>lib/isodoc/jis/html_convert.rb:29: htmlintropage: html_doc_path("html_jis_intro.html"), | d678bf45d98281cc269a0d1338ca32563252d723 |
| m3aawg | lib/isodoc/m3aawg/html/html_m3d_intro.html<br>lib/isodoc/m3aawg/html/html_m3d_titlepage.html | lib/isodoc/m3aawg/html_convert.rb:8: class HtmlConvert < IsoDoc::Generic::HtmlConvert | 141bcc472288d97e3115c310240606b48fbbf519 |
| mpfa | lib/isodoc/mpfa/html/html_rsd_intro.html<br>lib/isodoc/mpfa/html/html_rsd_titlepage.html | lib/isodoc/mpfa/html_convert.rb:11: class HtmlConvert < IsoDoc::HtmlConvert<br>lib/isodoc/mpfa/html_convert.rb:32: htmlcoverpage: html_doc_path("html_rsd_titlepage.html"),<br>lib/isodoc/mpfa/html_convert.rb:33: htmlintropage: html_doc_path("html_rsd_intro.html"), | 85f11a566c9c00c62dbb58409cb53ca4329dc74f |
| nist | lib/isodoc/nist/html/html_nist_intro.html<br>lib/isodoc/nist/html/html_nist_titlepage.html | lib/isodoc/nist/html_convert.rb:11: class HtmlConvert < IsoDoc::HtmlConvert<br>lib/isodoc/nist/html_convert.rb:36: htmlcoverpage: html_doc_path("html_nist_titlepage.html"),<br>lib/isodoc/nist/html_convert.rb:37: htmlintropage: html_doc_path("html_nist_intro.html"),<br>lib/isodoc/nist/html_convert.rb:82: def authority_cleanup(docxml) | 40029199d3cf17b32d541de28bb14868335eee03 |
| ogc | lib/isodoc/ogc/html/html_ogc_intro.html<br>lib/isodoc/ogc/html/html_ogc_titlepage.html<br>spec/assets/htmlintropage.html | lib/isodoc/ogc/html_convert.rb:9: class HtmlConvert < IsoDoc::HtmlConvert<br>lib/isodoc/ogc/html_convert.rb:29: htmlcoverpage: html_doc_path("html_ogc_titlepage.html"),<br>lib/isodoc/ogc/html_convert.rb:30: htmlintropage: html_doc_path("html_ogc_intro.html"),<br>lib/isodoc/ogc/html_convert.rb:57: def authority_cleanup(docxml) | 92a9133e34b38cb1dca6217795170a4137263298 |
| plateau | Inherited/configured cover | lib/isodoc/plateau/html_convert.rb:5: class HtmlConvert < IsoDoc::Jis::HtmlConvert | 60d02099e5e8f5c9d2a4529f0153965bb9bcf41f |
| ribose | lib/isodoc/ribose/html/html_rsd_intro.html<br>lib/isodoc/ribose/html/html_rsd_titlepage.html | lib/isodoc/ribose/html_convert.rb:11: class HtmlConvert < IsoDoc::Generic::HtmlConvert | dc142f99acf24e84ad801ff6413267885d81c5de |
| un | lib/isodoc/un/html/html_unece_intro.html<br>lib/isodoc/un/html/html_unece_plenary_titlepage.html<br>lib/isodoc/un/html/html_unece_titlepage.html<br>spec/assets/htmlintropage.html | lib/isodoc/un/html_convert.rb:10: class HtmlConvert < IsoDoc::HtmlConvert<br>lib/isodoc/un/html_convert.rb:41: htmlcoverpage: html_doc_path("html_unece_titlepage.html"),<br>lib/isodoc/un/html_convert.rb:42: htmlintropage: html_doc_path("html_unece_intro.html"),<br>lib/isodoc/un/html_convert.rb:58: @htmlcoverpage == html_doc_path("html_unece_titlepage.html")<br>lib/isodoc/un/html_convert.rb:59: @htmlcoverpage = html_doc_path("html_unece_plenary_titlepage.html") | 345ba67319ae0ce0ca80f01f9d3f5fa67bc8f40e |

## Taste configs (13 measured)

| Taste | Base | Legacy HTML overrides |
|---|---|---|
| csa | generic | html_csa_titlepage.html, html_csa_intro.html |
| dsa | iso | inherited |
| elf | iso | inherited |
| enosema | iso | inherited |
| iala | iho | html_iala_titlepage.html |
| icc | iso | htmlcoverpage.html |
| jcgm | iso | inherited |
| mbxif | ribose | inherited |
| oiml | iso | inherited |
| oiml-cs | config inheritance | inherited |
| pdfa | ribose | htmlcoverpage.html |
| swf | ribose | inherited |
| wmo | iho | inherited |

Taste revision: 36b7e017ed780dc62002a1cbbc17a7b9e8a12b99. Flavor HTML implementations and taste config/templates remain read-only inputs. B2 owns theme migration; B3 owns per-flavor override ports. This inventory does not equate a mechanism with a completed port.

## Implementation order and acceptance

1. Add a headless variant through the public generator, preserving body behavior while omitting the head and using an outer div.
2. Render form controls directly from typed models via Liquid; fix footnote reference identity and layout during rendering.
3. Add config-driven cover/titlepage/intro slots with typed front-matter data. Document replacement for legacy destination IDs and template metadata; exercise template overrides with real models.

Every missing row must be implemented or have an explicit documented replacement. Outstanding model ownership or per-flavor parity gaps must remain visible; no retirement or dispatch flip is authorized by this work.
