const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());
// In-memory mock database
let walletBalance = 25000.00;
let transactions = [
  {
    id: "TXN-101",
    type: "CREDIT",
    amount: 5000.0,
    currency: "INR",
    beneficiaryName: "Salary Credit",
    status: "SUCCESS",
    createdAt: new Date(Date.now() - 86400000).toISOString()
  },
  {
    id: "TXN-102",
    type: "DEBIT",
    amount: 850.0,
    currency: "INR",
    beneficiaryName: "Electricity Bill",
    status: "SUCCESS",
    createdAt: new Date(Date.now() - 43200000).toISOString()
  }
];
// Root test route
app.get('/', (req, res) => {
  res.json({ message: "JWallet API is live and running!" });
});
// 1. LOGIN API: POST /api/v1/auth/login
app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: "Email/Mobile and password are required"
    });
  }
  // Demo authentication check
  return res.json({
    success: true,
    data: {
      accessToken: "jwt_token_sample_" + Date.now(),
      user: {
        id: "usr_9981",
        name: email.split('@')[0] || "JWallet User",
        email: email
      }
    }
  });
});
// 2. WALLET BALANCE API: GET /api/v1/wallet/balance
app.get('/api/v1/wallet/balance', (req, res) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return res.status(401).json({ success: false, message: "Unauthorized: Token missing" });
  }
  res.json({
    success: true,
    data: {
      walletId: "JW-8842109",
      currency: "INR",
      availableBalance: walletBalance,
      maskedAccountNumber: "•••• •••• •••• 8842"
    }
  });
});
// 3. TRANSFER MONEY API: POST /api/v1/transactions/transfer
app.post('/api/v1/transactions/transfer', (req, res) => {
  const { beneficiaryName, mobileNumber, amount, remarks } = req.body;
  const transferAmount = parseFloat(amount);
  if (!beneficiaryName || !mobileNumber || !transferAmount || transferAmount <= 0) {
    return res.status(400).json({
      success: false,
      message: "Invalid transfer details"
    });
  }
  if (transferAmount > walletBalance) {
    return res.status(400).json({
      success: false,
      message: "Insufficient wallet balance"
    });
  }
  // Deduct balance
  walletBalance -= transferAmount;
  const newTxn = {
    id: "TXN-" + Math.floor(100000 + Math.random() * 900000),
    type: "DEBIT",
    amount: transferAmount,
    currency: "INR",
    beneficiaryName: beneficiaryName,
    status: "SUCCESS",
    createdAt: new Date().toISOString()
  };
  transactions.unshift(newTxn);
  res.json({
    success: true,
    data: {
      transactionId: newTxn.id,
      status: "SUCCESS",
      amount: transferAmount,
      currency: "INR",
      availableBalance: walletBalance
    }
  });
});
// 4. TRANSACTIONS LIST API: GET /api/v1/transactions
app.get('/api/v1/transactions', (req, res) => {
  res.json({
    success: true,
    data: transactions
  });
});
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`JWallet API running on port ${PORT}`);
});