import urllib.request
import json
import urllib.error
def fetch_versions(package_jsonurl):
    """
    Fetches package versions from a PyPI JSON URL and returns a sorted list of releases.
    Only includes versions that:
    - Have a wheel distribution available (packagetype = bdist_wheel)
    - Are compatible with Python 3.x (excludes Python 2.7)
    - Haven't been yanked from PyPI

    Args:
        package_jsonurl (str): The URL to the PyPI JSON API endpoint for a package
                             (e.g., "https://pypi.org/pypi/package-name/json")

    Returns:
        str: A JSON string containing a list of dictionaries, each with:
            - releaseLabel (str): The version number of the release
            - time (str): The upload timestamp of the release
            - release (str): The type of release (Alpha, Beta, Release Candidate, or full)
            - description (str): The description of the release
            The list is sorted by upload time in descending order (newest first).
            Returns an empty JSON array string "[]" if the fetch fails.

    Example:
        >>> versions = fetch_versions("https://pypi.org/pypi/cwmaya/json")
        >>> print(versions)
        '[{"releaseLabel": "1.0.0", "time": "2023-01-01T12:00:00", "release": "full", "description": ""}]'
    """


    try:
        with urllib.request.urlopen(package_jsonurl) as response:
            if response.status != 200:
                return []
            data = json.loads(response.read())
    except urllib.error.URLError as e:
        print(f"Error fetching package versions: {e}")
        return []

    result = []
    releases = data["releases"]

    latest_versions = {
        "Full": None,
        "Release Candidate": None,
        "Beta": None,
        "Alpha": None
    }

    for release_label, release_info in releases.items():
        wheel = next(
            (
                release
                for release in release_info
                if release["packagetype"] == "bdist_wheel"
                and release["requires_python"] != "~=2.7"
                and not release["yanked"]
            ),
            None,
        )

        if wheel:
            # Determine the release type
            if 'a' in release_label:
                release_type = "Alpha"
            elif 'b' in release_label:
                release_type = "Beta"
            elif 'rc' in release_label:
                release_type = "Release Candidate"
            else:
                release_type = "Full"

            # Get the description if available
            description = wheel.get("description", "")

            version_info = {
                "releaseLabel": release_label,
                "time": wheel["upload_time"],
                "releaseType": release_type,
                "description": description
            }

            # Update the latest version of each type
            if (latest_versions[release_type] is None or
                    wheel["upload_time"] > latest_versions[release_type]["time"]):
                latest_versions[release_type] = version_info

            result.append(version_info)

    # Determine the latest version based on the hierarchy
    latest_version = None
    for release_type in ["Full", "Release Candidate", "Beta", "Alpha"]:
        if latest_versions[release_type]:
            latest_version = latest_versions[release_type]
            break

    # Add the "latest" column
    for version_info in result:
        version_info["latest"] = "Latest" if version_info == latest_version else ""

    result.sort(key=lambda x: x["time"], reverse=True)
    
    
    
    
    
    return json.dumps(result)


def main():
    """
    Main function to demonstrate package version fetching.
    Fetches and prints versions for the cwmaya package.
    """
    package_jsonurl = "https://pypi.org/pypi/cwmaya/json"
    versions = json.loads(fetch_versions(package_jsonurl))
    for version in versions:
        print(f"|{version['releaseLabel']}|{version['time']}|{version['releaseType']}|{version['description']}|{version['latest']}|")
    


if __name__ == "__main__":
    main()
