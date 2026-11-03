-- ==============================================================================
-- KASIRPRO: SMART POS MOBILE - DATABASE SCHEMA (SUPABASE POSTGRESQL)
-- Production Multi-Tenant Schema with Row Level Security (RLS) & RPC Functions
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Custom Types
CREATE TYPE user_role AS ENUM ('owner', 'admin', 'cashier');
CREATE TYPE stock_movement_type AS ENUM ('PURCHASE', 'SALE', 'SALE_RETURN', 'PURCHASE_RETURN', 'ADJUSTMENT', 'STOCK_OPNAME');
CREATE TYPE payment_method AS ENUM ('CASH', 'QRIS', 'TRANSFER', 'DEBIT', 'EWALLET', 'MIXED');
CREATE TYPE transaction_status AS ENUM ('COMPLETED', 'PENDING', 'CANCELLED', 'REFUNDED');
CREATE TYPE debt_status AS ENUM ('UNPAID', 'PARTIAL', 'PAID', 'OVERDUE');
CREATE TYPE expense_category AS ENUM ('RENT', 'ELECTRICITY', 'WATER', 'SALARY', 'TRANSPORT', 'OPERATIONAL', 'MAINTENANCE', 'OTHER');

-- 1. Businesses Table (Tenants)
CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    address TEXT,
    phone VARCHAR(50),
    currency VARCHAR(10) DEFAULT 'IDR',
    timezone VARCHAR(50) DEFAULT 'Asia/Jakarta',
    tax_rate NUMERIC(5,2) DEFAULT 0.00,
    logo_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Branches Table (Multi-branch)
CREATE TABLE branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(50),
    is_main BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Profiles / Users Table
CREATE TABLE profiles (
    id UUID PRIMARY KEY, -- Maps to auth.users.id
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    role user_role DEFAULT 'cashier',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Categories Table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50) DEFAULT 'category',
    color VARCHAR(20) DEFAULT '#2D6A4F',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Units Table
CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Customers Table
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(255),
    address TEXT,
    total_spend NUMERIC(15,2) DEFAULT 0.00,
    active_debt NUMERIC(15,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Suppliers Table
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(255),
    address TEXT,
    total_purchased NUMERIC(15,2) DEFAULT 0.00,
    active_payable NUMERIC(15,2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Products Table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) NOT NULL,
    barcode VARCHAR(100),
    description TEXT,
    buy_price NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    sell_price NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    current_stock NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    min_stock NUMERIC(10,2) NOT NULL DEFAULT 5.00,
    unit VARCHAR(20) DEFAULT 'pcs',
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_sku_per_business UNIQUE (business_id, sku),
    CONSTRAINT unique_barcode_per_business UNIQUE (business_id, barcode)
);

-- 9. Transactions (Sales Header)
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
    cashier_id UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    invoice_number VARCHAR(100) NOT NULL,
    subtotal NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    discount_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    discount_percent NUMERIC(5,2) NOT NULL DEFAULT 0.00,
    tax_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    total_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    payment_method payment_method NOT NULL DEFAULT 'CASH',
    cash_received NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    change_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    status transaction_status NOT NULL DEFAULT 'COMPLETED',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_invoice_per_business UNIQUE (business_id, invoice_number)
);

-- 10. Transaction Items (Sales Detail)
CREATE TABLE transaction_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    product_name VARCHAR(255) NOT NULL,
    sku VARCHAR(100),
    barcode VARCHAR(100),
    buy_price NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    sell_price NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    quantity NUMERIC(10,2) NOT NULL DEFAULT 1.00,
    discount_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    subtotal_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. Payments Table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    payment_method payment_method NOT NULL DEFAULT 'CASH',
    amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    reference_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. Stock Movements (Audit Trail for Inventory)
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    movement_type stock_movement_type NOT NULL,
    previous_stock NUMERIC(10,2) NOT NULL,
    quantity_changed NUMERIC(10,2) NOT NULL,
    remaining_stock NUMERIC(10,2) NOT NULL,
    reference_id VARCHAR(100), -- invoice or purchase order number
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 13. Stock Opnames Table
CREATE TABLE stock_opnames (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    opname_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_discrepancy_items INT DEFAULT 0,
    notes TEXT,
    status VARCHAR(50) DEFAULT 'COMPLETED',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 14. Stock Opname Items
CREATE TABLE stock_opname_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stock_opname_id UUID NOT NULL REFERENCES stock_opnames(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    system_stock NUMERIC(10,2) NOT NULL,
    physical_stock NUMERIC(10,2) NOT NULL,
    difference NUMERIC(10,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 15. Debts (Customer Piutang / Hutang Pelanggan)
CREATE TABLE debts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL,
    invoice_number VARCHAR(100) NOT NULL,
    total_debt NUMERIC(15,2) NOT NULL,
    paid_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    remaining_debt NUMERIC(15,2) NOT NULL,
    due_date DATE NOT NULL,
    status debt_status NOT NULL DEFAULT 'UNPAID',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 16. Debt Payments (Cicilan Hutang Pelanggan)
CREATE TABLE debt_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    debt_id UUID NOT NULL REFERENCES debts(id) ON DELETE CASCADE,
    amount NUMERIC(15,2) NOT NULL,
    payment_method payment_method DEFAULT 'CASH',
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 17. Receivables / Supplier Payables (Hutang Toko ke Supplier)
CREATE TABLE receivables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    purchase_reference VARCHAR(100) NOT NULL,
    total_bill NUMERIC(15,2) NOT NULL,
    paid_amount NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    remaining_bill NUMERIC(15,2) NOT NULL,
    due_date DATE NOT NULL,
    status debt_status NOT NULL DEFAULT 'UNPAID',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 18. Receivable Payments (Cicilan Hutang ke Supplier)
CREATE TABLE receivable_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    receivable_id UUID NOT NULL REFERENCES receivables(id) ON DELETE CASCADE,
    amount NUMERIC(15,2) NOT NULL,
    payment_method payment_method DEFAULT 'CASH',
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 19. Expenses (Pengeluaran Operasional)
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(id) ON DELETE SET NULL,
    category expense_category NOT NULL DEFAULT 'OPERATIONAL',
    amount NUMERIC(15,2) NOT NULL,
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    description TEXT NOT NULL,
    receipt_url TEXT,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 20. Printers Table
CREATE TABLE printers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    mac_address VARCHAR(100),
    paper_size VARCHAR(10) DEFAULT '58mm',
    is_default BOOLEAN DEFAULT FALSE,
    is_connected BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 21. Notifications Table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'SYSTEM',
    is_read BOOLEAN DEFAULT FALSE,
    payload JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 22. Audit Logs Table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_name VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- INDEXES FOR MAXIMUM QUERY PERFORMANCE
-- ==============================================================================
CREATE INDEX idx_products_business ON products(business_id);
CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_transactions_business_branch ON transactions(business_id, branch_id);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_transactions_invoice ON transactions(invoice_number);
CREATE INDEX idx_transaction_items_tx ON transaction_items(transaction_id);
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_debts_customer ON debts(customer_id);
CREATE INDEX idx_receivables_supplier ON receivables(supplier_id);
CREATE INDEX idx_expenses_business_date ON expenses(business_id, expense_date);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Multi-Tenant Isolation: Users can ONLY access data belonging to their business
-- ==============================================================================
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_opnames ENABLE ROW LEVEL SECURITY;
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE debt_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE receivables ENABLE ROW LEVEL SECURITY;
ALTER TABLE receivable_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE printers ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Helper function to get current user's business_id
CREATE OR REPLACE FUNCTION get_user_business_id()
RETURNS UUID AS $$
  SELECT business_id FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper function to get current user's role
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS user_role AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Business RLS
CREATE POLICY "Users can access their own business" ON businesses
  FOR ALL USING (id = get_user_business_id());

-- Branches RLS
CREATE POLICY "Users can access their business branches" ON branches
  FOR ALL USING (business_id = get_user_business_id());

-- Products RLS
CREATE POLICY "Users can view products in their business" ON products
  FOR SELECT USING (business_id = get_user_business_id());

CREATE POLICY "Owners and Admins can insert/update products" ON products
  FOR ALL USING (
    business_id = get_user_business_id() AND
    get_user_role() IN ('owner', 'admin')
  );

-- Transactions RLS
CREATE POLICY "Users can access transactions in their business" ON transactions
  FOR ALL USING (business_id = get_user_business_id());

CREATE POLICY "Users can access transaction items" ON transaction_items
  FOR ALL USING (
    transaction_id IN (SELECT id FROM transactions WHERE business_id = get_user_business_id())
  );

-- Stock Movements RLS
CREATE POLICY "Users can access stock movements in their business" ON stock_movements
  FOR ALL USING (business_id = get_user_business_id());

-- Expenses RLS (Owners & Admins only for full financial view)
CREATE POLICY "Users can view and record expenses in their business" ON expenses
  FOR ALL USING (business_id = get_user_business_id());

-- Debts & Receivables RLS
CREATE POLICY "Users can access debts in their business" ON debts
  FOR ALL USING (business_id = get_user_business_id());

CREATE POLICY "Users can access receivables in their business" ON receivables
  FOR ALL USING (business_id = get_user_business_id());

-- ==============================================================================
-- STORED PROCEDURE / RPC: ATOMIC PROCESS POS TRANSACTION
-- Prevents race conditions, deducts stock atomically, and logs stock movement
-- ==============================================================================
CREATE OR REPLACE FUNCTION process_pos_transaction(
    p_business_id UUID,
    p_branch_id UUID,
    p_cashier_id UUID,
    p_customer_id UUID,
    p_invoice_number VARCHAR,
    p_subtotal NUMERIC,
    p_discount_amount NUMERIC,
    p_discount_percent NUMERIC,
    p_tax_amount NUMERIC,
    p_total_amount NUMERIC,
    p_payment_method payment_method,
    p_cash_received NUMERIC,
    p_change_amount NUMERIC,
    p_items JSONB,
    p_notes TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_transaction_id UUID;
    v_item JSONB;
    v_product_id UUID;
    v_qty NUMERIC;
    v_buy_price NUMERIC;
    v_sell_price NUMERIC;
    v_current_stock NUMERIC;
    v_new_stock NUMERIC;
    v_prod_name VARCHAR;
    v_sku VARCHAR;
    v_barcode VARCHAR;
    v_subtotal_item NUMERIC;
BEGIN
    -- 1. Insert header transaction
    INSERT INTO transactions (
        business_id, branch_id, cashier_id, customer_id, invoice_number,
        subtotal, discount_amount, discount_percent, tax_amount, total_amount,
        payment_method, cash_received, change_amount, status, notes
    ) VALUES (
        p_business_id, p_branch_id, p_cashier_id, p_customer_id, p_invoice_number,
        p_subtotal, p_discount_amount, p_discount_percent, p_tax_amount, p_total_amount,
        p_payment_method, p_cash_received, p_change_amount, 'COMPLETED', p_notes
    ) RETURNING id INTO v_transaction_id;

    -- 2. Process each cart item atomically
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::UUID;
        v_qty := (v_item->>'quantity')::NUMERIC;
        v_sell_price := (v_item->>'sell_price')::NUMERIC;
        v_subtotal_item := (v_item->>'subtotal_amount')::NUMERIC;

        -- Lock product row for atomic update
        SELECT name, sku, barcode, buy_price, current_stock
        INTO v_prod_name, v_sku, v_barcode, v_buy_price, v_current_stock
        FROM products
        WHERE id = v_product_id AND business_id = p_business_id
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Product with ID % not found.', v_product_id;
        END IF;

        -- Calculate stock
        v_new_stock := v_current_stock - v_qty;

        -- Update product stock
        UPDATE products
        SET current_stock = v_new_stock,
            updated_at = NOW()
        WHERE id = v_product_id;

        -- Insert transaction item
        INSERT INTO transaction_items (
            transaction_id, product_id, product_name, sku, barcode,
            buy_price, sell_price, quantity, discount_amount, subtotal_amount
        ) VALUES (
            v_transaction_id, v_product_id, v_prod_name, v_sku, v_barcode,
            v_buy_price, v_sell_price, v_qty, COALESCE((v_item->>'discount_amount')::NUMERIC, 0.0), v_subtotal_item
        );

        -- Record stock movement audit
        INSERT INTO stock_movements (
            business_id, branch_id, product_id, movement_type,
            previous_stock, quantity_changed, remaining_stock,
            reference_id, user_id, notes
        ) VALUES (
            p_business_id, p_branch_id, v_product_id, 'SALE',
            v_current_stock, -v_qty, v_new_stock,
            p_invoice_number, p_cashier_id, 'Penjualan Kasir POS'
        );
    END LOOP;

    -- 3. Update customer total spend if customer attached
    IF p_customer_id IS NOT NULL THEN
        UPDATE customers
        SET total_spend = total_spend + p_total_amount,
            updated_at = NOW()
        WHERE id = p_customer_id;
    END IF;

    RETURN v_transaction_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

