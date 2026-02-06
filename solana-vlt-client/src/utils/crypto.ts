import * as crypto from "crypto";

/**
 * Genera un hash SHA256 a partir de la ubicación, el peso y la marca de tiempo.
 * @param location - La ubicación de la prueba de litio.
 * @param weight - El peso de la prueba de litio.
 * @param timestamp - La marca de tiempo de la prueba de litio.
 * @returns Un hash en formato hexadecimal.
 */
export function generateLithiumProofHash(
  location: string,
  weight: number,
  timestamp: number
): string {
  const data = `${location}:${weight}:${timestamp}`;
  const hash = crypto.createHash("sha256").update(data).digest("hex");
  return `0x${hash}`;
}