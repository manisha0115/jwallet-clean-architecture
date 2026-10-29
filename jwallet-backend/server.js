const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());


let walletBalance = 25450.75;
const VALID_TOKEN = "mock_access_token_123";


let transactions = [
  {
    id: "TXN10001",
    type: "DEBIT",
    amount: 1500.00,
    currency: "INR",
    beneficiaryName: "Rahul Sharma",
    status: "SUCCESS",
    createdAt: "2026-10-20T10:30:00Z"
  },
  {
    id: "TXN10002",
    type: "CREDIT",
    amount: 5000.00,
    currency: "INR",
    beneficiaryName: "Amit Kumar",
    status: "SUCCESS",
    createdAt: "2026-10-19T14:15:00Z"
  },
  {
    id: "TXN10003",
    type: "DEBIT",
    amount: 450.00,
    currency: "INR",
    beneficiaryName: "Swiggy Order",
    status: "SUCCESS",
    createdAt: "2026-10-18T19:45:00Z"
  },
  {
    id: "TXN10004",
    type: "CREDIT",
    amount: 12000.00,
    currency: "INR",
    beneficiaryName: "Freelance Payment",
    status: "SUCCESS",
    createdAt: "2026-10-17T09:10:00Z"
  },
  {
    id: "TXN10005",
    type: "DEBIT",
    amount: 2199.00,
    currency: "INR",
    beneficiaryName: "Amazon India",
    status: "SUCCESS",
    createdAt: "2026-10-16T16:20:00Z"
  },
  {
    id: "TXN10006",
    type: "DEBIT",
    amount: 650.00,
    currency: "INR",
    beneficiaryName: "Electricity Bill",
    status: "SUCCESS",
    createdAt: "2026-10-15T11:05:00Z"
  },
  {
    id: "TXN10007",
    type: "CREDIT",
    amount: 2500.00,
    currency: "INR",
    beneficiaryName: "Priya Singh",
    status: "SUCCESS",
    createdAt: "2026-10-14T13:30:00Z"
  },
  {
    id: "TXN10008",
    type: "DEBIT",
    amount: 199.00,
    currency: "INR",
    beneficiaryName: "Netflix Subscription",
    status: "SUCCESS",
    createdAt: "2026-10-13T08:00:00Z"
  },
  {
    id: "TXN10009",
    type: "DEBIT",
    amount: 800.00,
    currency: "INR",
    beneficiaryName: "Petrol Pump",
    status: "SUCCESS",
    createdAt: "2026-10-12T17:50:00Z"
  },
  {
    id: "TXN10010",
    type: "CREDIT",
    amount: 3000.00,
    currency: "INR",
    beneficiaryName: "Cashback Reward",
    status: "SUCCESS",
    createdAt: "2026-10-11T12:15:00Z"
  }
];

// Health check
app.get('/', (req, res) => {
  res.json({ status: "online", message: "JWallet API is operational" });
});

// Auth check middleware
function checkAuth(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: "Unauthorized: Token missing" });
  }

  const token = authHeader.split(' ')[1];
  if (token !== VALID_TOKEN) {
    return res.status(401).json({ success: false, message: "Unauthorized: Invalid token" });
  }

  next();
}

// 1. LOGIN API: POST /api/v1/auth/login
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body;

  if (email === "demo@jstack.co" && password === "Demo@123") {
    return res.status(200).json({
      success: true,
      data: {
        accessToken: VALID_TOKEN,
        user: {
          id: "USR10001",
          name: "Demo User",
          email: "demo@jstack.co"
        }
      }
    });
  }

  // Invalid credentials MUST return HTTP 401
  return res.status(401).json({
    success: false,
    message: "Invalid credentials. Use demo@jstack.co and Demo@123"
  });
});

// 2. WALLET BALANCE: GET /api/v1/wallet/balance
app.get('/api/v1/wallet/balance', checkAuth, (req, res) => {
  res.status(200).json({
    success: true,
    data: {
      walletId: "WALLET10001",
      currency: "INR",
      availableBalance: parseFloat(walletBalance.toFixed(2)),
      maskedAccountNumber: "XXXX XXXX 4589"
    }
  });
});

// 3. TRANSACTIONS LIST: GET /api/v1/transactions
app.get('/api/v1/transactions', checkAuth, (req, res) => {
  res.status(200).json({
    success: true,
    data: transactions
  });
});

// 4. MONEY TRANSFER: POST /api/v1/transactions/transfer
let nextTxnId = 10011;


app.post('/api/v1/transactions/transfer', checkAuth, (req, res) => {
  const {
    beneficiaryName,
    mobileNumber,
    amount,
    remarks = ''
  } = req.body;

  const idempotencyKey = req.get('Idempotency-Key');
  const token = req.get('Authorization');

  if (!idempotencyKey) {
    return res.status(400).json({
      success: false,
      message: 'Idempotency-Key header is required'
    });
  }

  // Scope the key to the authenticated request.
  const requestKey = `${token}:${idempotencyKey}`;

  // Return the original response if the same request is retried.
  if (processedTransfers.has(requestKey)) {
    const previous = processedTransfers.get(requestKey);

    return res.status(previous.statusCode).json(previous.body);
  }

  const transferAmount = Number(amount);
  const normalizedMobile = String(mobileNumber || '').trim();
  const normalizedName = String(beneficiaryName || '').trim();

  if (
    !normalizedName ||
    !/^[0-9]{10}$/.test(normalizedMobile) ||
    !Number.isFinite(transferAmount) ||
    transferAmount <= 0 ||
    !/^\d+(\.\d{1,2})?$/.test(String(amount)) ||
    !Number.isFinite(transferAmount * 100) ||
    !Number.isSafeInteger(Math.round(transferAmount * 100))
  ) {
    return res.status(400).json({
      success: false,
      message: 'Enter valid beneficiary details and amount'
    });
  }

  // Compare integer paise to avoid floating-point balance errors.
  const amountInPaise = Math.round(transferAmount * 100);
  const balanceInPaise = Math.round(walletBalance * 100);

  if (amountInPaise > balanceInPaise) {
    return res.status(400).json({
      success: false,
      message: 'Insufficient wallet balance'
    });
  }

  // Perform the transfer once.
  walletBalance = (balanceInPaise - amountInPaise) / 100;

  const transactionId = `TXN${nextTxnId++}`;

  const newTxn = {
    id: transactionId,
    type: 'DEBIT',
    amount: amountInPaise / 100,
    currency: 'INR',
    beneficiaryName: normalizedName,
    mobileNumber: normalizedMobile,
    remarks: String(remarks || '').trim(),
    status: 'SUCCESS',
    createdAt: new Date().toISOString()
  };

  transactions.unshift(newTxn);

  const responseBody = {
    success: true,
    data: {
      transactionId,
      status: 'SUCCESS',
      amount: amountInPaise / 100,
      currency: 'INR',
      availableBalance: Number(walletBalance.toFixed(2))
    }
  };

  // Save the result only after the transfer succeeds.
  processedTransfers.set(requestKey, {
    statusCode: 200,
    body: responseBody
  });

  return res.status(200).json(responseBody);
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`JWallet API running on port ${PORT}`);
});