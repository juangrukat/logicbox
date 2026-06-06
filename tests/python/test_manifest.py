import json

from logicbox_cli.manifest import read_manifest, write_manifest


def test_manifest_contains_only_operational_metadata(tmp_path):
    path = tmp_path / "manifest.json"
    write_manifest(
        path,
        {
            "run_id": "20260606T000000Z-abcd1234",
            "status": "completed",
            "artifacts": [
                {
                    "path": "schema/accepted.shen",
                    "sha256": "a" * 64,
                    "bytes": 42,
                }
            ],
        },
    )

    data = read_manifest(path)
    assert data["run_id"] == "20260606T000000Z-abcd1234"
    serialized = json.dumps(data)
    assert "[plan " not in serialized
    assert "payload" not in serialized
    assert not list(tmp_path.glob(".manifest.json.*.tmp"))


def test_read_manifest_rejects_non_object(tmp_path):
    path = tmp_path / "manifest.json"
    path.write_text("[]\n", encoding="utf-8")

    try:
        read_manifest(path)
    except ValueError as error:
        assert "not an object" in str(error)
    else:
        raise AssertionError("expected non-object manifest rejection")
