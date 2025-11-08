-- Enable Row Level Security on the products table
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Policy 1: Allow anyone to read products (public catalog)
CREATE POLICY "Allow public read access to products"
ON public.products
FOR SELECT
USING (true);

-- Policy 2: Allow anyone to insert products (public contributions)
CREATE POLICY "Allow public insert access to products"
ON public.products
FOR INSERT
WITH CHECK (true);

-- Policy 3: Allow anyone to update products
CREATE POLICY "Allow public update access to products"
ON public.products
FOR UPDATE
USING (true)
WITH CHECK (true);

-- Policy 4: Allow anyone to delete products
CREATE POLICY "Allow public delete access to products"
ON public.products
FOR DELETE
USING (true);

-- Note: These policies allow full public access, which matches your current use case
-- If you later want to restrict access, you can modify these policies
-- For example, you could require authentication for INSERT/UPDATE/DELETE:
-- CREATE POLICY "Allow authenticated users to insert products"
-- ON public.products
-- FOR INSERT
-- WITH CHECK (auth.role() = 'authenticated');



