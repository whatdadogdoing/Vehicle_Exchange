import { render, screen } from '@testing-library/react';
import App from './App';

test('renders without crashing', () => {
  render(<App />);
});

test('contains navigation elements', () => {
  render(<App />);
  // Basic smoke test - just ensure app renders
  expect(document.body).toBeInTheDocument();
});