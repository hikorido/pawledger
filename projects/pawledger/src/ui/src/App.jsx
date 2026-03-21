import { BrowserRouter, Routes, Route } from "react-router-dom";
import { LocaleProvider } from "./hooks/useLocale";
import { WalletProvider } from "./hooks/useWallet";
import { ContractProvider } from "./hooks/useContract";
import Navbar from "./components/layout/Navbar";
import Footer from "./components/layout/Footer";
import Home from "./pages/Home";
import CaseBrowser from "./pages/CaseBrowser";
import CaseDetail from "./pages/CaseDetail";
import SubmitCase from "./pages/SubmitCase";
import RescuerDashboard from "./pages/RescuerDashboard";
import DonorDashboard from "./pages/DonorDashboard";
import ReviewerDashboard from "./pages/ReviewerDashboard";

export default function App() {
  return (
    <LocaleProvider>
      <WalletProvider>
        <ContractProvider>
          <BrowserRouter>
            <div className="min-h-screen flex flex-col bg-gray-50">
              <Navbar />
              <main className="flex-1">
                <Routes>
                  <Route path="/" element={<Home />} />
                  <Route path="/cases" element={<CaseBrowser />} />
                  <Route path="/case/:id" element={<CaseDetail />} />
                  <Route path="/submit" element={<SubmitCase />} />
                  <Route path="/dashboard/rescuer" element={<RescuerDashboard />} />
                  <Route path="/dashboard/donor" element={<DonorDashboard />} />
                  <Route path="/dashboard/reviewer" element={<ReviewerDashboard />} />
                </Routes>
              </main>
              <Footer />
            </div>
          </BrowserRouter>
        </ContractProvider>
      </WalletProvider>
    </LocaleProvider>
  );
}
