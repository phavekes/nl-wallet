#[cfg(feature = "software-integration-test")]
#[test]
fn test_storage_path() {
    use platform_support::{integration_test::utils::get_and_verify_storage_path, utils::software::SoftwareUtilities};

    assert!(get_and_verify_storage_path::<SoftwareUtilities>());
}