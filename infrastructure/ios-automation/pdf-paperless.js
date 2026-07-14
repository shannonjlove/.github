/**
 * Scriptable.app - PDF to Paperless-NGX
 *
 * Features:
 * - Capture PDF from Photos/Files
 * - Extract text with OCR (via VPS)
 * - Auto-tag and categorize
 * - Send to Paperless-NGX
 * - Track in Bookstack
 *
 * Installation: Copy code to Scriptable app
 */

const CONFIG = {
  VPS_URL: "http://72.61.74.250:8813",
  VPS_API_KEY: "9d7a77b557782e91e7bd7f79884098c80e495eb4adfd17598e60737770bf5687",
  PAPERLESS_URL: "http://72.61.74.250:8080",
  PAPERLESS_TOKEN: "", // Set in settings
  LOG_URL: "http://72.61.74.250:8813/execute"
};

// ============================================================================
// Main PDF Processing
// ============================================================================

async function processPDF() {
  let alert = new Alert();
  alert.title = "📄 PDF to Paperless-NGX";
  alert.message = "What would you like to do?";
  alert.addAction("📱 Select from Photos");
  alert.addAction("📁 Select from Files");
  alert.addAction("📷 Scan Document");
  alert.addAction("❌ Cancel");

  let choice = await alert.presentSheet();

  switch(choice) {
    case 0:
      await processFromPhotos();
      break;
    case 1:
      await processFromFiles();
      break;
    case 2:
      await scanDocument();
      break;
    default:
      return;
  }
}

/**
 * Process PDF from iPhone Photos
 */
async function processFromPhotos() {
  try {
    // Note: Scriptable has limited Photos access
    // This would require using DocumentPickerViewController or similar
    let alert = new Alert();
    alert.title = "📱 Photos to PDF";
    alert.message = "This feature requires iPhone Photos integration.\n\nFor now, use 'Files' option instead.";
    alert.addAction("OK");
    await alert.present();

    await processFromFiles();

  } catch(e) {
    notify(`Error: ${e.message}`);
  }
}

/**
 * Process PDF from Files app
 */
async function processFromFiles() {
  try {
    let fm = FileManager.iCloud();

    // Get file list
    let alert = new Alert();
    alert.title = "📁 Select PDF File";
    alert.message = "Enter PDF file path:";
    alert.addTextField("File path", "/var/podman/documents/document.pdf");
    alert.addAction("Process");
    alert.addCancelAction("Cancel");

    if (await alert.present() != 0) return;

    let filePath = alert.textFieldValue(0);

    // Get document details
    let detailsAlert = new Alert();
    detailsAlert.title = "📋 Document Details";
    detailsAlert.message = "Add metadata for better organization:";
    detailsAlert.addTextField("Document Title", "Invoice");
    detailsAlert.addTextField("Tags (comma-separated)", "invoice, 2026");
    detailsAlert.addSegmentedControl("Type", ["Invoice", "Receipt", "Document", "Contract", "Other"], 0);
    detailsAlert.addAction("Upload");
    detailsAlert.addCancelAction("Cancel");

    if (await detailsAlert.present() != 0) return;

    let title = detailsAlert.textFieldValue(0);
    let tags = detailsAlert.textFieldValue(1);
    let docType = ["Invoice", "Receipt", "Document", "Contract", "Other"][detailsAlert.selectedSegmentIndex()];

    // Process PDF
    notify("🔄 Processing PDF...");

    // Step 1: Extract text from PDF (via VPS)
    let extractResult = await extractPDFText(filePath);

    // Step 2: Upload to Paperless-NGX
    let uploadResult = await uploadToPaperlessNGX(filePath, title, tags, docType);

    if (uploadResult.success) {
      // Step 3: Log operation
      await logPDFOperation({
        filename: filePath,
        title: title,
        tags: tags,
        type: docType,
        document_id: uploadResult.document_id,
        extracted_text: extractResult.text ? "Yes" : "No",
        timestamp: new Date().toISOString()
      });

      notify(`✅ PDF uploaded to Paperless\nID: ${uploadResult.document_id}\nTags: ${tags}`);
    } else {
      notify("❌ Failed to upload PDF");
    }

  } catch(e) {
    notify(`Error: ${e.message}`);
  }
}

/**
 * Scan document using device camera
 */
async function scanDocument() {
  try {
    let alert = new Alert();
    alert.title = "📷 Scan Document";
    alert.message = "Document scanning would capture via camera.\n\nFor now, this is a placeholder.\n\nUse 'Select from Files' to process existing PDFs.";
    alert.addAction("OK");
    await alert.present();

  } catch(e) {
    notify(`Error: ${e.message}`);
  }
}

// ============================================================================
// PDF Operations
// ============================================================================

/**
 * Extract text from PDF using VPS
 */
async function extractPDFText(filePath) {
  try {
    // Use pdftotext on VPS
    let command = `pdftotext "${filePath}" - | head -500`;
    let result = await sendVPSCommand(command);

    return {
      success: result.success,
      text: result.success ? result.stdout : ""
    };
  } catch(e) {
    return { success: false, error: e.message };
  }
}

/**
 * Upload to Paperless-NGX
 */
async function uploadToPaperlessNGX(filePath, title, tags, docType) {
  try {
    // For demo: use VPS to upload to Paperless
    let curlCommand = `
      curl -X POST \
        -H "Authorization: Token ${CONFIG.PAPERLESS_TOKEN}" \
        -F "document=@${filePath}" \
        -F "title=${title}" \
        -F "tags=${tags}" \
        "${CONFIG.PAPERLESS_URL}/api/documents/"
    `;

    let result = await sendVPSCommand(curlCommand);

    if (result.success) {
      // Parse response to get document ID
      let responseJson = JSON.parse(result.stdout);
      return {
        success: true,
        document_id: responseJson.id
      };
    } else {
      return { success: false, error: result.stderr };
    }

  } catch(e) {
    return { success: false, error: e.message };
  }
}

/**
 * Process with OCR (optional, slower)
 */
async function processWithOCR(filePath) {
  try {
    // Use Tesseract on VPS for OCR
    let command = `tesseract "${filePath}" stdout`;
    let result = await sendVPSCommand(command);

    return {
      success: result.success,
      text: result.success ? result.stdout : ""
    };
  } catch(e) {
    return { success: false, error: e.message };
  }
}

/**
 * Auto-categorize document
 */
async function autoCategorizePDF(title, extractedText) {
  // Simple heuristic-based categorization
  let categories = {
    "Invoice": ["invoice", "bill", "amount due"],
    "Receipt": ["receipt", "paid", "total"],
    "Contract": ["agreement", "contract", "terms"],
    "Report": ["report", "analysis", "summary"]
  };

  for (let [category, keywords] of Object.entries(categories)) {
    let text = (title + " " + extractedText).toLowerCase();
    if (keywords.some(kw => text.includes(kw))) {
      return category;
    }
  }

  return "Document";
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Send command to VPS
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
      stderr: response.stderr
    };
  } catch(e) {
    return { success: false, error: e.message };
  }
}

/**
 * Log PDF operation to Bookstack
 */
async function logPDFOperation(details) {
  try {
    let command = `python3 /home/user/.github/infrastructure/event-logging/bookstack-event-logger.py "pdf-processing" '${JSON.stringify(details)}'`;
    await sendVPSCommand(command);
  } catch(e) {
    console.log("Failed to log operation");
  }
}

/**
 * Show notification
 */
function notify(message) {
  let notification = new Notification();
  notification.title = "📄 PDF to Paperless";
  notification.body = message;
  notification.schedule();
}

// ============================================================================
// Entry Point
// ============================================================================

await processPDF();
