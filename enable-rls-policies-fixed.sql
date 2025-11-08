-- Step 1: Enable Row Level Security on the products table
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Step 2: Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Allow public read access to products" ON public.products;
DROP POLICY IF EXISTS "Allow public insert access to products" ON public.products;
DROP POLICY IF EXISTS "Allow public update access to products" ON public.products;
DROP POLICY IF EXISTS "Allow public delete access to products" ON public.products;

-- Step 3: Create policies for public access

-- Policy 1: Allow anyone to read products (public catalog)
CREATE POLICY "Allow public read access to products"
ON public.products
FOR SELECT
TO public
USING (true);

-- Policy 2: Allow anyone to insert products (public contributions)
CREATE POLICY "Allow public insert access to products"
ON public.products
FOR INSERT
TO public
WITH CHECK (true);

-- Policy 3: Allow anyone to update products
CREATE POLICY "Allow public update access to products"
ON public.products
FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

-- Policy 4: Allow anyone to delete products
CREATE POLICY "Allow public delete access to products"
ON public.products
FOR DELETE
TO public
USING (true);

-- Verify RLS is enabled
SELECT 
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'products';



