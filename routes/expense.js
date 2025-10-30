const express = require('express');
const router = express.Router();
const Expense = require('../models/Expense');
const auth = require('../middleware/auth');

// Get all expenses (public)
router.get('/', async (req, res) => {
  try {
    const expenses = await Expense.find().sort({ createdAt: -1 });
    res.json(expenses);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Add expense (protected)
router.post('/', auth, async (req, res) => {
  try {
    const { date, description, category, amount } = req.body;
    
    const expense = new Expense({
      date,
      description,
      category,
      amount
    });

    await expense.save();
    res.status(201).json(expense);
  } catch (error) {
    res.status(400).json({ message: 'Error adding expense', error: error.message });
  }
});

// Delete expense (protected)
router.delete('/:id', auth, async (req, res) => {
  try {
    const expense = await Expense.findByIdAndDelete(req.params.id);
    if (!expense) {
      return res.status(404).json({ message: 'Expense not found' });
    }
    res.json({ message: 'Expense deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get summary (public)
router.get('/summary', async (req, res) => {
  try {
    const expenses = await Expense.find();
    const totalSpent = expenses.reduce((sum, exp) => sum + exp.amount, 0);
    const totalBudget = 150000;
    const remaining = totalBudget - totalSpent;

    res.json({
      totalBudget,
      totalSpent,
      remaining
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
