from pathlib import Path


PRESERVED = (
    "shen/fact-schema.shen",
    "shen/fact-normalize.shen",
    "shen/fact-provenance.shen",
    "shen/fact-typecheck.shen",
    "shen/fact-regression.shen",
    "shen/rules.shen",
)


def test_preserved_engine_files_exist():
    for name in PRESERVED:
        assert Path(name).is_file(), name


def test_legacy_orchestration_is_absent_after_cleanup():
    for name in ("scripts", "work", "output", "logicbox (skill)"):
        assert not Path(name).exists(), name
