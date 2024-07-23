# Magento Installation Script

This script automates the installation of Magento on a Linux server. It updates and upgrades the system, installs necessary packages, configures Apache, MySQL, PHP, Elasticsearch, Composer, and Magento.

## Prerequisites

- A Linux server (Ubuntu preferred)
- Root or sudo access

## Usage

1. Clone the repository or download the script to your server.
2. Make the script executable:
    ```bash
    chmod +x install_magento.sh
    ```
3. Run the script:
    ```bash
    sudo ./install_magento.sh
    ```

## Script Details

The script performs the following actions:

1. **System Update and Upgrade**
   - Updates and upgrades the system packages.

2. **Install Apache and MySQL**
   - Installs Apache and MySQL server.
   - Secures MySQL installation and creates a database and user for Magento.

3. **Install PHP and Required Extensions**
   - Installs PHP and necessary extensions.
   - Detects the installed PHP version and updates `php.ini` settings.

4. **Restart Apache**
   - Restarts Apache to apply the changes.

5. **Install Elasticsearch**
   - Installs Elasticsearch 7.x, starts, and enables it.

6. **Install Composer**
   - Installs Composer globally.

7. **Set Magento Authentication Keys**
   - Configures Magento authentication keys in Composer.

8. **Download and Set Up Magento**
   - Downloads and sets up Magento in the specified directory.
   - Configures Apache for Magento.

9. **Install Magento**
   - Runs the Magento installation with provided parameters.

10. **Set Magento to Developer Mode and Install Sample Data**
    - Sets Magento to developer mode.
    - Installs Magento sample data.
    - Cleans and flushes Magento cache.

11. **Additional Configurations**
    - Applies additional Magento configurations.

## Configuration

Before running the script, update the following placeholders with your own values:

- `YOUR_PUBLIC_KEY`
- `YOUR_PRIVATE_KEY`

## Apache Configuration

The script configures Apache to point to the Magento installation directory and sets the server name to the server's IP address.

## Magento Installation

The script installs Magento with the following parameters:

- `--base-url`: The base URL for the Magento store.
- `--db-host`: Database host (localhost).
- `--db-name`: Database name (magento).
- `--db-user`: Database user (magento_user).
- `--db-password`: Database user password (password).
- `--admin-firstname`: Admin first name (Admin).
- `--admin-lastname`: Admin last name (Admin).
- `--admin-email`: Admin email (admin@admin.com).
- `--admin-user`: Admin username (admin).
- `--admin-password`: Admin password (admin123).
- `--language`: Language (en_US).
- `--currency`: Currency (USD).
- `--timezone`: Timezone (America/Chicago).
- `--use-rewrites`: Use URL rewrites (1).

## Notes

- Ensure that you have the correct permissions to execute the script.
- The script must be run with sudo to install packages and make system-wide changes.
- The script sets the default database password to `password`. Change this to a secure password for production use.

## License

This project is licensed under the MIT License.

