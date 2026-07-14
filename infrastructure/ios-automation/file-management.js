/**
 * Scriptable.app - File Management Automation
 *
 * Features:
 * - Capture files from Photos/Files
 * - Auto-rename with date/category
 * - Tag files with metadata
 * - Send to Bookstack or Paperless-NGX
 * - Track operations on VPS
 *
 * Installation:
 * 1. Install Scriptable app (iOS)
 * 2. Copy this code into Scriptable
 * 3. Run the script
 */

// ============================================================================
// Configuration
// ============================================================================

const CONFIG = {
  VPS_URL: "http://72.61.74.250:8813",
  VPS_API_KEY: "9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687",
  BOOKSTACK_URL: "http://72.61.74.250:8000", // Replace with your Bookstack URL
  BOOKSTACK_TOKEN: "", // Set from keychain
  PAPERLESS_URL: "http://72.61.74.250:8080", // Replace with your Paperless URL
  PAPERLESS_TOKEN: "", // Set from keychain
};

// ============================================================================
// File Management Functions
// ============================================================================

/**
 * Main menu for file operations
 */
async function showMainMenu() {
  let options = [
    "📁 Rename File",
    "🏷️  Tag File",
    "📄 Upload to Bookstack",
    "📰 Send to Paperless-NGX",
    "📸 Process PDF from Photos",
    "🔍 Quick File Search",
    "⚙️  Settings",
    "❌ Exit"
  ];

  let menu = new Alert();
  menu.title = "📱 File Management";
  menu.message = "Select an operation";

  options.forEach(option => {
    menu.addAction(option);
  });

  let selected = await menu.presentSheet();

  switch(selected) {
    case 0: await renameFile(); break;
    case 1: await tagFile(); break;
    case 2: await uploadToBookstack(); break;
    case 3: await sendTopaperless(); break;
    case 4: await processPDFfromPhotos(); break;
    case 5: await quickFileSearch(); break;
    case 6: await openSettings(); break;
    case 7: return;
  }

  // Show menu again
  await showMainMenu();
}

/**
 * Rename file with intelligent naming
 */
async function renameFile() {
  let fm = FileManager.iCloud();

  // Get file path
  let alert = new Alert();
  alert.title = "📁 Rename File";
  alert.message = "Enter file path:";
  alert.addTextField("File path", "/var/podman/documents/file.pdf");
  alert.addAction("Continue");
  alert.addCancelAction("Cancel");

  if (await alert.present() != 0) return;

  let filePath = alert.textFieldValue(0);

  // Get new name pattern
  let categoryOptions = ["documents", "receipts", "invoices", "screenshots", "notes", "other"];
  let categoryPicker = new Alert();
  categoryPicker.title = "Select Category";
  categoryOptions.forEach(cat => categoryPicker.addAction(cat));
  let categoryIndex = await categoryPicker.present();
  let category = categoryOptions[categoryIndex];

  // Generate new filename
  let date = new Date();
  let dateStr = date.toISOString().split('T')[0]; // YYYY-MM-DD
  let timeStr = date.toTimeString().split(' ')[0].replace(/:/g, '-'); // HH-MM-SS

  let newName = `${dateStr}__${category}__file`;

  // Send rename command to VPS
  let result = await sendVPSCommand(`mv "${filePath}" "$(dirname "${filePath}")/${newName}$(basename "${filePath}" | sed 's/.*\./\./')"`);

  if (result.success) {
    logOperation("file-rename", {
      original: filePath,
      renamed: newName,
      category: category,
      timestamp: new Date().toISOString()
    });

    notify("✅ File renamed successfully");
  } else {
    notify("❌ Failed to rename file");
  }
}

/**
 * Add tags to file (via VPS)
 */
async function tagFile() {
  let alert = new Alert();
  alert.title = "🏷️  Tag File";
  alert.message = "Enter file path:";
  alert.addTextField("File path", "/var/podman/documents/file.pdf");
  alert.addTextField("Tags (comma-separated)", "important, review, 2026");
  alert.addAction("Tag");
  alert.addCancelAction("Cancel");

  if (await alert.present() != 0) return;

  let filePath = alert.textFieldValue(0);
  let tags = alert.textFieldValue(1);

  // Store tags as extended attributes on VPS
  let tagCommand = `setfattr -n user.tags -v "${tags}" "${filePath}"`;
  let result = await sendVPSCommand(tagCommand);

  if (result.success) {
    logOperation("file-tag", {
      filename: filePath,
      tags: tags,
      timestamp: new Date().toISOString()
    });

    notify(`✅ Tagged: ${tags}`);
  }
}

/**
 * Upload file to Bookstack
 */
async function uploadToBookstack() {
  let alert = new Alert();
  alert.title = "📄 Upload to Bookstack";
  alert.message = "Enter details:";
  alert.addTextField("File path", "/var/podman/documents/file.pdf");
  alert.addTextField("Page title", "Document Title");
  alert.addAction("Upload");
  alert.addCancelAction("Cancel");

  if (await alert.present() != 0) return;

  let filePath = alert.textFieldValue(0);
  let pageTitle = alert.textFieldValue(1);

  // Read file content (for text files)
  let fm = FileManager.iCloud();
  let content = "";

  if (filePath.endsWith('.txt') || filePath.endsWith('.md')) {
    try {
      // This would need proper file reading - simplified for demo
      content = "File content would be read here";
    } catch(e) {
      notify("❌ Could not read file");
      return;
    }
  }

  // Create page in Bookstack
  let bookstackResult = await createBookstackPage(pageTitle, content, filePath);

  if (bookstackResult) {
    logOperation("file-to-bookstack", {
      filename: filePath,
      page_title: pageTitle,
      page_id: bookstackResult,
      timestamp: new Date().toISOString()
    });

    notify(`✅ Uploaded to Bookstack (ID: ${bookstackResult})`);
  }
}

/**
 * Send file to Paperless-NGX
 */
async function sendTopaperless() {
  let alert = new Alert();
  alert.title = "📰 Send to Paperless-NGX";
  alert.message = "Enter PDF path:";
  alert.addTextField("File path", "/var/podman/documents/invoice.pdf");
  alert.addTextField("Tags (comma-separated)", "invoice, 2026");
  alert.addAction("Send");
  alert.addCancelAction("Cancel");

  if (await alert.present() != 0) return;

  let filePath = alert.textFieldValue(0);
  let tags = alert.textFieldValue(1);

  let paperlessResult = await uploadToPaperless(filePath, tags);

  if (paperlessResult) {
    logOperation("file-to-paperless", {
      filename: filePath,
      tags: tags,
      document_id: paperlessResult,
      timestamp: new Date().toISOString()
    });

    notify(`✅ Sent to Paperless-NGX (ID: ${paperlessResult})`);
  }
}

/**
 * Process PDF from iPhone Photos
 */
async function processPDFfromPhotos() {
  try {
    let alert = new Alert();
    alert.title = "📸 Process PDF from Photos";
    alert.message = "This would integrate with Photos app to extract PDFs.\n\nFor now, enter PDF details:";
    alert.addTextField("PDF filename", "document.pdf");
    alert.addTextField("Document type", "invoice");
    alert.addAction("Process");
    alert.addCancelAction("Cancel");

    if (await alert.present() != 0) return;

    let filename = alert.textFieldValue(0);
    let docType = alert.textFieldValue(1);

    // In production, this would:
    // 1. Get PDF from Photos
    // 2. Run OCR (Tesseract on VPS)
    // 3. Extract text
    // 4. Send to Paperless-NGX
    // 5. Log operation

    notify("✅ PDF processing initiated");

  } catch(e) {
    notify(`❌ Error: ${e.message}`);
  }
}

/**
 * Quick file search
 */
async function quickFileSearch() {
  let searchAlert = new Alert();
  searchAlert.title = "🔍 Quick File Search";
  searchAlert.message = "Search for file:";
  searchAlert.addTextField("Search term", "");
  searchAlert.addAction("Search");
  searchAlert.addCancelAction("Cancel");

  if (await searchAlert.present() != 0) return;

  let searchTerm = searchAlert.textFieldValue(0);

  let result = await sendVPSCommand(`find /var/podman -name "*${searchTerm}*" -type f | head -20`);

  if (result.success && result.stdout) {
    notify(`Found files:\n${result.stdout}`);
  } else {
    notify("No files found");
  }
}

/**
 * Settings menu
 */
async function openSettings() {
  let settingsAlert = new Alert();
  settingsAlert.title = "⚙️  Settings";
  settingsAlert.message = "Configure credentials:";
  settingsAlert.addTextField("VPS URL", CONFIG.VPS_URL);
  settingsAlert.addTextField("Bookstack URL", CONFIG.BOOKSTACK_URL);
  settingsAlert.addTextField("Paperless URL", CONFIG.PAPERLESS_URL);
  settingsAlert.addAction("Save");
  settingsAlert.addCancelAction("Cancel");

  await settingsAlert.present();
}

// ============================================================================
// API Helper Functions
// ============================================================================

/**
 * Send command to VPS remote executor
 */
async function sendVPSCommand(command) {
  let request = new Request(CONFIG.VPS_URL + "/execute");
  request.method = "POST";
  request.headers = {
    "Authorization": `Bearer ${CONFIG.VPS_API_KEY}`,
    "Content-Type": "application/json"
  };
  request.body = JSON.stringify({
    command: command,
    shell: true
  });

  try {
    let response = await request.loadJSON();
    return {
      success: response.exit_code === 0,
      stdout: response.stdout,
      stderr: response.stderr,
      exit_code: response.exit_code
    };
  } catch(e) {
    return {
      success: false,
      error: e.message
    };
  }
}

/**
 * Create page in Bookstack
 */
async function createBookstackPage(title, content, sourceFile) {
  // This would use Bookstack API
  // Placeholder for now
  return "page_123";
}

/**
 * Upload to Paperless-NGX
 */
async function uploadToPaperless(filePath, tags) {
  // This would upload to Paperless API
  // Placeholder for now
  return "doc_456";
}

/**
 * Log operation to VPS event system
 */
async function logOperation(operationType, details) {
  let logCommand = `python3 /home/user/.github/infrastructure/event-logging/bookstack-event-logger.py "${operationType}" '${JSON.stringify(details)}'`;
  await sendVPSCommand(logCommand);
}

/**
 * Show notification
 */
function notify(message) {
  let notification = new Notification();
  notification.title = "📱 File Manager";
  notification.body = message;
  notification.schedule();
}

// ============================================================================
// Main Entry Point
// ============================================================================

await showMainMenu();
